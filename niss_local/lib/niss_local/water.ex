defmodule NissLocal.Water do
  alias Circuits.GPIO

  def pump_for!(name, secs) do
    pin = pump_pin(name)
    {:ok, pin} = GPIO.open(pin, :output, initial_value: 1)
    :timer.sleep(secs * 1_000)
    GPIO.write(pin, 0)
  end

  def level!(name) do
    level_pins(name)
    |> Enum.map(fn {height, pin} -> {height, read_level_pin(pin)} end)
  end

  defp read_level_pin(num) do
    {:ok, pin} = GPIO.open(num, :input, pull_mode: :pulldown)
    GPIO.read(pin)
  end

  defp pump_pin(:chillies), do: 4
  defp pump_pin(:lime), do: 26

  defp level_pins(:chillies),
    do: [
      {5, 27},
      {10, 22},
      {15, 5},
      {20, 6},
      {25, 13}
    ]

  defp level_pins(:lime),
    do: [
      {10, 24},
      {20, 25},
      {30, 12}
    ]
end
