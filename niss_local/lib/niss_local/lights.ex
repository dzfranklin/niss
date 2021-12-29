defmodule NissLocal.Lights do
  @moduledoc """
  tinytuya set up following readme.
  See <https://github.com/jasonacox/tinytuya>.

  I couldn't get the IPs with `python3 -m tinytuya scan` so I got them with a
  network scanner (the device IPs on Tuya Cloud are something different).
  """
  require Logger

  def set!(status) do
    fetch_configs!()
    |> Enum.map(fn {_name, config} ->
      Task.async(fn -> set_by!(config, status) end)
    end)
    |> Task.await_many(:timer.minutes(5))

    nil
  end

  def set!(name, status) do
    name
    |> fetch_config!()
    |> set_by!(status)
  end

  defp set_by!(config, status) do
    {:ok, _} =
      run_tuya(config, [
        "set_status",
        if(status, do: "true", else: "false")
      ])

    if get_by!(config) != status do
      raise "new status not reflected"
    end

    nil
  end

  def get! do
    fetch_configs!()
    |> Enum.map(fn {name, config} ->
      Task.async(fn -> {name, get_by!(config)} end)
    end)
    |> Task.await_many(:timer.minutes(5))
  end

  def get!(name) do
    name
    |> fetch_config!()
    |> get_by!()
  end

  defp get_by!(config) do
    {:ok, stdout} = run_tuya(config, ["get_status"])

    case String.trim(stdout) do
      "1" -> true
      "0" -> false
    end
  end

  defp fetch_configs! do
    Application.fetch_env!(:niss_local, NissLocal.Lights)
    |> Keyword.fetch!(:plugs)
  end

  defp fetch_config!(name) do
    fetch_configs!()
    |> Keyword.fetch!(name)
  end

  defp run_tuya(config, args) do
    label = Keyword.fetch!(config, :label)
    id = Keyword.fetch!(config, :id)
    ip = Keyword.fetch!(config, :ip)
    key = Keyword.fetch!(config, :key)

    Logger.debug("Trying to manipulate plug labelled #{inspect(label)}: #{inspect(args)}")

    args =
      [
        "--id",
        id,
        "--ip",
        ip,
        "--key",
        key
      ] ++ args

    %Porcelain.Result{err: stderr, out: stdout, status: status} =
      Porcelain.exec(tuya_bin(), args, out: :string, err: :string)

    if status == 0 do
      if stderr == "" do
        Logger.info(
          "Successfully manipulated plug labelled #{inspect(label)}: #{inspect(args)}. stderr:\n#{stderr}"
        )
      else
        Logger.info(
          "Successfully manipulated plug labelled #{inspect(label)}: #{inspect(args)}, but stderr:\n#{stderr}"
        )
      end

      {:ok, stdout}
    else
      if stdout == "" do
        Logger.warn("Failed to manipulate plug labelled #{inspect(label)}, stderr:\n#{stderr}")
      else
        Logger.warn(
          "Failed to manipulate plug labelled #{inspect(label)},\nstdout:\n#{stdout}\nstderr:\n#{stderr}"
        )
      end

      :error
    end
  end

  defp tuya_bin, do: Path.join([NissLocal.scripts_dir(), "tuya.py"])
end
