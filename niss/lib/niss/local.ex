defmodule Niss.Local do
  @type name :: atom()
  @type height_mm :: non_neg_integer()
  @type duration_secs :: non_neg_integer()

  @adapter Application.compile_env!(:niss, :adapters)[:local]

  @callback set_lights!(bool) :: nil
  defdelegate set_lights!(status), to: @adapter

  @callback set_light!(name(), bool()) :: nil
  defdelegate set_light!(name, status), to: @adapter

  @callback light_status!(name()) :: bool()
  defdelegate light_status!(name), to: @adapter

  @callback water_levels!(name()) :: [{height_mm(), bool()}]
  defdelegate water_levels!(name), to: @adapter

  @callback pump_for!(name(), duration_secs()) :: nil
  defdelegate pump_for!(name, secs), to: @adapter
end
