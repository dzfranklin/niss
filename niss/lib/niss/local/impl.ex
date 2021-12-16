defmodule Niss.Local.Impl do
  @behaviour Niss.Local

  @impl true
  def set_lights!(status), do: rpc!(Lights, :set!, [status])

  @impl true
  def set_light!(name, status), do: rpc!(Lights, :set!, [name, status])

  @impl true
  def light_status!(name), do: rpc!(Lights, :get!, [name])

  @impl true
  def water_levels!(name), do: rpc!(Water, :levels!, [name])

  @impl true
  def pump_for!(name, secs), do: rpc!(Water, :pump_for!, [name, secs])

  defp rpc!(mod, fun, args) do
    node = Application.get_env(:niss, Niss.Local)[:local_node]
    mod = Module.concat(NissLocal, mod)
    :erpc.call(node, mod, fun, args)
  end
end
