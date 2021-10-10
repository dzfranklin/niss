defmodule NissFw.CeilingLights.FigureOutRemote do
  alias Circuits.GPIO
  require Logger

  @sensor_pin 23

  def start do
    {:ok, pin} = GPIO.open(@sensor_pin, :input)
    GPIO.set_pull_mode(pin, :pullup)

    spawn(fn ->
      GPIO.set_interrupts(pin, :both)
      record_loop([])
    end)
  end

  def stop(pid) do
    send(pid, {:stop, self()})

    receive do
      {:result, state} ->
        GPIO.close(@sensor_pin)
        state_to_result(state)
    end
  end

  defp record_loop(state) do
    receive do
      {:stop, caller} ->
        send(caller, {:result, state})
        nil

      # NOTE: Time is monotonic in the native time unit. However, it is not the same monotonic time
      #   as :erlang.monotonic_time. See <https://github.com/elixir-circuits/circuits_gpio/issues/3>
      {:circuits_gpio, @sensor_pin, time, value} ->
        record_loop([{time, value} | state])
    end
  end

  defp state_to_result(state) do
    {initial_time, _} = hd(state)

    state
    |> Enum.reverse()
    |> Enum.map(fn {time, value} -> {time - initial_time, value} end)
  end
end
