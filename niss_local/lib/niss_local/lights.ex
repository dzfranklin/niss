defmodule NissLocal.Lights do
  @moduledoc """
  tinytuya set up following readme.
  See <https://github.com/jasonacox/tinytuya>.

  I couldn't get the IPs with `python3 -m tinytuya scan` so I got them with a
  network scanner (the device IPs on Tuya Cloud are something different).
  """
  require Logger

  def set!(name, status) do
    fetch_config!(name)
    |> run_tuya([
      "set_status",
      if(status, do: "true", else: "false")
    ])
  end

  def get!(name) do
    {:ok, stdout} =
      fetch_config!(name)
      |> run_tuya(["get_status"])

    case String.trim(stdout) do
      "1" -> true
      "0" -> false
    end
  end

  def fetch_config!(name) do
    Application.fetch_env!(:niss_local, NissLocal.Lights)
    |> Keyword.fetch!(:plugs)
    |> Keyword.fetch!(name)
  end

  defp run_tuya(config, args) do
    label = Keyword.fetch!(config, :label)
    id = Keyword.fetch!(config, :id)
    ip = Keyword.fetch!(config, :ip)
    key = Keyword.fetch!(config, :key)

    Logger.debug("Trying to manipulate plug labelled #{inspect(label)}: #{inspect(args)}")

    {stdout, status} =
      System.cmd(
        tuya_bin(),
        [
          "--id",
          id,
          "--ip",
          ip,
          "--key",
          key
        ] ++ args
      )

    if status == 0 do
      Logger.debug("Successfully manipulated plug labelled #{inspect(label)}")
      {:ok, stdout}
    else
      Logger.warn("Failed to manipulate plug labelled #{inspect(label)}, got stdout:\n#{stdout}")
      :error
    end
  end

  defp tuya_bin, do: Path.join([NissLocal.scripts_dir(), "tuya.py"])
end
