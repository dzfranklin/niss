defmodule NissLocal.Lights do
  @moduledoc """
  tinytuya set up following readme.
  See <https://github.com/jasonacox/tinytuya>.

  I couldn't get the IPs with `python3 -m tinytuya scan` so I got them with a
  network scanner (the device IPs on Tuya Cloud are something different).
  """
  require Logger

  def set_plug(name, status) do
    config =
      Application.fetch_env!(:niss_local, NissLocal.Lights)
      |> Keyword.fetch!(:plugs)
      |> Keyword.fetch!(name)

    Logger.info("Setting #{inspect(name)} to #{inspect(status)}")

    set_by_config(config, status)
  end

  defp set_by_config(config, status) do
    label = Keyword.fetch!(config, :label)
    id = Keyword.fetch!(config, :id)
    ip = Keyword.fetch!(config, :ip)
    key = Keyword.fetch!(config, :key)
    status = if(status, do: "true", else: "false")

    Logger.debug("Trying to set plug labelled #{inspect(label)} to #{inspect(status)}")

    {logs, status} =
      System.cmd(
        tuya_bin(),
        [
          "--id",
          id,
          "--ip",
          ip,
          "--key",
          key,
          "--status",
          status
        ],
        stderr_to_stdout: true
      )

    if status == 0 do
      Logger.debug("Successfully set plug labelled #{inspect(label)} to #{inspect(status)}")
    else
      Logger.warn(
        "Failed to set plug labelled #{inspect(label)} to #{inspect(status)}, got:\n#{logs}"
      )
    end
  end

  defp tuya_bin, do: Path.join([NissLocal.scripts_dir(), "tuya.py"])
end
