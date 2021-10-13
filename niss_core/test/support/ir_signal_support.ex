defmodule NissCore.IRSignalSupport do
  def compress(points) do
    points
    |> Enum.map(fn {duration, value} ->
      Integer.to_string(value) <> Integer.to_string(duration)
    end)
    |> Enum.join(",")
    |> split_at_max_line()
    |> Enum.join("\n")
  end

  def decompress(s) do
    s
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.join("")
    |> String.split(",")
    |> Enum.map(fn <<value::binary-size(1), duration::binary>> ->
      {String.to_integer(duration), String.to_integer(value)}
    end)
  end

  defp split_at_max_line(s) do
    s
    |> String.to_charlist()
    |> Enum.chunk_while(
      [],
      fn char, acc ->
        if length(acc) == 80 do
          {:cont, Enum.reverse(acc), [char]}
        else
          {:cont, [char | acc]}
        end
      end,
      fn acc ->
        {:cont, Enum.reverse(acc), nil}
      end
    )
  end
end
