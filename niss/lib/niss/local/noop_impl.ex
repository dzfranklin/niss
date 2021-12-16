defmodule Niss.Local.NoopImpl do
  @behaviour Niss.Local
  require Logger

  @impl true
  def set_lights!(status) do
    Logger.warn("noop set_light!(#{inspect(status)})")
    nil
  end

  @impl true
  def set_light!(name, status) do
    Logger.warn("noop set_light!(#{inspect(name)}, #{inspect(status)})")
    nil
  end

  @impl true
  def light_status!(name) do
    Logger.warn("noop light_status!(#{inspect(name)})")
    false
  end

  @impl true
  def water_levels!(name) do
    Logger.warn("noop water_levels!(#{inspect(name)})")
    [{5, true}, {10, true}, {15, false}]
  end

  @impl true
  def pump_for!(name, secs) do
    Logger.warn("noop pump_for!(#{inspect(name)}, #{inspect(secs)})")
    Process.sleep(:timer.seconds(secs))
    nil
  end
end
