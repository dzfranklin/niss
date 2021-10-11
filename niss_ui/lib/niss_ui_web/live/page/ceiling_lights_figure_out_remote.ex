defmodule NissUiWeb.Live.Page.CeilingLightsFigureOutRemote do
  use NissUiWeb, :surface_view
  alias NissCore.RecordIR

  data recorder, :any, default: nil

  data recordings, :any, default: []

  @impl true
  def mount(_params, session, socket) do
    ensure_auth_live(session, socket)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~F"""
    {#if is_nil(@recorder)}
      <button :on-click="start" type="button">Start</button>
    {#else}
      <button :on-click="stop" type="button">Stop</button>
    {/if}

    <ul>
      {#for {data, idx} <- Enum.with_index(@recordings)}
        <li>
          <div>
            {plot(data)}

            <pre><code>
            {inspect(data, limit: :infinity)}
            </code></pre>
          </div>

          <div>
            <button :on-click="del-start" type="button" phx-value-idx={idx}>Delete start</button>
            <button :on-click="del-end" type="button" phx-value-idx={idx}>Delete end</button>
          </div>
        </li>
      {/for}
    </ul>
    """
  end

  @impl true
  def handle_event("start", _, socket) do
    recorder = RecordIR.start()
    {:noreply, assign(socket, recorder: recorder)}
  end

  @impl true
  def handle_event("stop", _, socket) do
    data =
      RecordIR.stop(socket.assigns.recorder)
      |> strip_leading_junk()
      |> strip_trailing_junk()

    socket =
      socket
      |> assign(recorder: nil)
      |> update(:recordings, &[data | &1])

    {:noreply, socket}
  end

  @impl true
  def handle_event("del-start", %{"idx" => idx}, socket) do
    {:noreply, update_recording(socket, idx, &tl(&1))}
  end

  @impl true
  def handle_event("del-end", %{"idx" => idx}, socket) do
    {:noreply, update_recording(socket, idx, &Enum.slice(&1, 0, length(&1) - 1))}
  end

  defp update_recording(socket, idx, mapper) do
    idx = String.to_integer(idx)

    update(socket, :recordings, fn recordings ->
      recordings
      |> Enum.with_index()
      |> Enum.map(fn {data, data_idx} ->
        if data_idx == idx do
          mapper.(data)
        else
          data
        end
      end)
    end)
  end

  def plot([]), do: []

  def plot(data) do
    data
    |> Enum.reduce(nil, fn {duration, value}, acc ->
      if is_nil(acc) do
        [{duration, value}, {0, value}]
      else
        {prev_t, _} = hd(acc)
        [{prev_t + duration, value} | [{prev_t + 1, value} | acc]]
      end
    end)
    |> Enum.reverse()
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.LinePlot, 2_000, 200, smoothed: false)
    |> Contex.Plot.to_svg()
  end

  @tolerance 0.3

  # Counts both ups and downs
  @leading_indicator_count 17
  @leading_indicator_length 600_000

  def strip_leading_junk(data) do
    Enum.reduce(data, {0, []}, fn {duration, value}, {count, out} ->
      if count == @leading_indicator_count do
        {count, [{duration, value} | out]}
      else
        if within_tolerance?(duration, @leading_indicator_length) do
          {count + 1, out}
        else
          {0, out}
        end
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  def strip_trailing_junk(data) do
    idx = packet_end_idx(data)
    Enum.slice(data, 0, idx)
  end

  @packet_end_high_count 3
  @packet_end_low_count 4
  @packet_end_high_length 1_600_000
  @packet_end_low_length 600_000

  defp packet_end_idx([]), do: 0

  defp packet_end_idx(data) do
    data
    |> Enum.with_index()
    |> Enum.reduce_while({0, 0}, fn {{duration, value}, idx}, {high_count, low_count} ->
      if high_count == @packet_end_high_count && low_count == @packet_end_low_count do
        {:halt, idx - @packet_end_high_count - @packet_end_low_count}
      else
        case value do
          0 ->
            if within_tolerance?(duration, @packet_end_low_length) do
              {:cont, {high_count, low_count + 1}}
            else
              {:cont, {0, 0}}
            end

          1 ->
            if within_tolerance?(duration, @packet_end_high_length) do
              {:cont, {high_count + 1, low_count}}
            else
              {:cont, {0, 0}}
            end
        end
      end
    end)
  end

  defp within_tolerance?(potential, expected) do
    potential > expected * (1.0 - @tolerance) && potential < expected * (1.0 + @tolerance)
  end
end
