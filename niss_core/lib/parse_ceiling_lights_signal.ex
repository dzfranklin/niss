defmodule NissCore.ParseCeilingLightsSignal do
  import NissCore, only: [within_tolerance?: 3, above_tolerance?: 3]
  require Logger
  @compile if Mix.env() == :test, do: :export_all

  @typedoc """
  0 represents a short pulse and 1 a long pulse
  """
  @type packet :: bitstring()
  @type invalid_packet :: [0 | 1 | term()]

  @spec parse(NissCore.RecordIR.recording()) :: [{:ok, packet()} | {:error, invalid_packet()}]
  def parse(signal) do
    signal
    |> sanity_check_values()
    |> group_into_packets()
    |> Enum.map(&packet_convert_to_valley_durations/1)
    |> Enum.map(&packet_convert_valley_durations_to_bits/1)
    |> Enum.map(&packet_convert_list_to_bitstring_or_invalid/1)
  end

  @low_bit_duration 550_000
  @high_bit_duration 550_000 * 3
  @bit_duration_tolerance 0.30

  defp sanity_check_values(signal) do
    Enum.map(signal, fn
      {_, 0} = point -> point
      {_, 1} = point -> point
      point -> raise "signal failed sanity check: invalid value in #{inspect(point)}"
    end)
  end

  defp group_into_packets(signal) do
    Enum.chunk_while(
      signal,
      nil,
      fn
        # Not in packet
        point, nil ->
          if is_packet_boundary?(point) do
            Logger.debug("Got packet start: #{inspect(point)}")
            {:cont, :seen_packet_start}
          else
            Logger.debug("Got non-packet: #{inspect(point)}")
            {:cont, nil}
          end

        # Possibly one bit into packet
        point, :seen_packet_start ->
          if is_packet_second_bit?(point) do
            Logger.debug("Seen packet second bit: #{inspect(point)}")
            {:cont, []}
          else
            Logger.debug("Got non-packet when expecting second bit: #{inspect(point)}")
            {:cont, nil}
          end

        # In packet
        point, acc ->
          if is_packet_boundary?(point) do
            Logger.debug("Got packet end: #{inspect(point)}")

            acc =
              case acc do
                [] ->
                  []

                [{duration, value} | rest] ->
                  if above_tolerance?(duration, @high_bit_duration, @bit_duration_tolerance) do
                    Logger.debug("Ignoring ending padding #{inspect({duration, value})}")
                    rest
                  else
                    [{duration, value} | rest]
                  end
              end

            {:cont, Enum.reverse(acc), nil}
          else
            Logger.debug("Got packet point: #{inspect(point)}")
            {:cont, [point | acc]}
          end
      end,
      fn acc ->
        if !is_nil(acc) do
          Logger.warn("group_into_packets/1: Discarding incomplete packet")
        end

        {:cont, nil}
      end
    )
  end

  defp is_packet_boundary?({duration, value}),
    do: value == 0 && within_tolerance?(duration, 9_100_000, 0.05)

  defp is_packet_second_bit?({duration, value}),
    do: value == 1 && within_tolerance?(duration, 4_500_000, 0.05)

  defp packet_convert_to_valley_durations(packet) do
    packet
    |> Enum.map(fn
      {duration, 0} ->
        if valid_pulse_duration?(duration) do
          :valid_pulse
        else
          {:unrecognized_pulse, duration}
        end

      {duration, 1} ->
        duration

      other ->
        other
    end)
    |> Enum.filter(&(&1 != :valid_pulse))
  end

  defp packet_convert_valley_durations_to_bits(packet) do
    packet
    |> Enum.map(fn
      duration when is_integer(duration) ->
        cond do
          within_tolerance?(duration, @low_bit_duration, @bit_duration_tolerance) ->
            0

          within_tolerance?(duration, @high_bit_duration, @bit_duration_tolerance) ->
            1

          true ->
            {:invalid_valley_duration, duration}
        end

      other ->
        other
    end)
  end

  defp packet_has_issue?(packet) do
    Enum.any?(packet, fn
      0 -> false
      1 -> false
      _other -> true
    end)
  end

  defp packet_convert_list_to_bitstring_or_invalid(packet) do
    if packet_has_issue?(packet) do
      {:error, packet}
    else
      {:ok, Enum.into(packet, <<>>, &<<&1::1>>)}
    end
  end

  defp valid_pulse_duration?(duration), do: within_tolerance?(duration, 600_000, 0.1)
end
