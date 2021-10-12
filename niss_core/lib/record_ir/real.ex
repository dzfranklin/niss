defmodule NissCore.RecordIR.Real do
  alias Circuits.GPIO
  require Logger

  @sensor_pin 23

  def start do
    {:ok, pin} = GPIO.open(@sensor_pin, :input)
    :ok = GPIO.set_pull_mode(pin, :pullup)

    spawn(fn ->
      :ok = GPIO.set_interrupts(pin, :both)
      record_loop(pin, [])
    end)
  end

  def stop(pid) do
    send(pid, {:stop, self()})

    receive do
      {:result, pin, state} ->
        :ok = GPIO.close(pin)
        state_to_result(state)
    end
  end

  defp record_loop(pin, state) do
    receive do
      {:stop, caller} ->
        send(caller, {:result, pin, state})
        nil

      # NOTE: Time is monotonic in the native time unit. However, it is not the same monotonic time
      #   as :erlang.monotonic_time. See <https://github.com/elixir-circuits/circuits_gpio/issues/3>
      {:circuits_gpio, @sensor_pin, time, value} ->
        record_loop(pin, [{time, value} | state])
    end
  end

  defp state_to_result(state) do
    state
    |> Enum.reverse()
    |> Enum.chunk_every(2, 1)
    |> Enum.map(fn
      [{time_start, value}, {time_end, _}] ->
        delta =
          (time_end - time_start)
          # At least right now, these units are equal. This is mostly for clarity.
          |> :erlang.convert_time_unit(:native, :nanosecond)

        {delta, value}

      [_last] ->
        nil
    end)
    |> Enum.filter(&(!is_nil(&1)))
  end
end
