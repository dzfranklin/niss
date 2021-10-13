defmodule NissUiWeb.Live.Page.CeilingLightsFigureOutRemote do
  use NissUiWeb, :surface_view
  alias NissCore.{RecordIR, ParseCeilingLightsSignal}
  require Logger

  data recorder, :any, default: nil
  data recordings, :any, default: %{}
  data recordings_length, :integer, default: 0
  data show_raw?, :boolean, default: false

  @impl true
  def mount(_params, session, socket) do
    ensure_auth_live(session, socket)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      {#if is_nil(@recorder)}
        <button :on-click="start" type="button">Start</button>
      {#else}
        <button :on-click="stop" type="button">Stop</button>
      {/if}

      {#if @show_raw?}
        <button :on-click="show-raw-off" type="button">Show parsed</button>
      {#else}
        <button :on-click="show-raw-on" type="button">Show raw</button>
      {/if}
    </div>

    <ul>
      {#for {id, recording} <- ordered_recordings(@recordings, @recordings_length)}
        <li :if={!is_nil(recording)}>
          {#if @show_raw?}
            {plot(recording.trimmed_raw)}

            <pre><code>
              {inspect(recording.trimmed_raw, limit: :infinity)}
            </code></pre>

            <div>
              <button :on-click="recording-trim-start" type="button" phx-value-id={id}>Trim start</button>
              <button :on-click="recording-trim-end" type="button" phx-value-id={id}>Trim end</button>
              <button :on-click="recording-trim-reset" type="button" phx-value-id={id}>Reset trimming</button>
            </div>
          {#else}
            <pre><code>
              {inspect(recording.parsed, limit: :infinity)}
            </code></pre>
          {/if}

          <button :on-click="recording-del" type="button" phx-value-id={id}>Delete recording</button>
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
    raw = RecordIR.stop(socket.assigns.recorder)

    recording = %{
      raw: raw,
      trimmed_raw: raw,
      parsed: ParseCeilingLightsSignal.parse(raw)
    }

    socket =
      socket
      |> assign(recorder: nil)
      |> update(:recordings, &Map.put(&1, socket.assigns.recordings_length, recording))
      |> update(:recordings_length, &(&1 + 1))

    {:noreply, socket}
  end

  @impl true
  def handle_event("show-raw-off", _, socket) do
    {:noreply, assign(socket, show_raw?: false)}
  end

  @impl true
  def handle_event("show-raw-on", _, socket) do
    {:noreply, assign(socket, show_raw?: true)}
  end

  @impl true
  def handle_event("recording-trim-start", %{"id" => id}, socket) do
    {:noreply, update_recording_trimmed(socket, id, &tl(&1))}
  end

  @impl true
  def handle_event("recording-trim-end", %{"id" => id}, socket) do
    {:noreply, update_recording_trimmed(socket, id, &Enum.slice(&1, 0, length(&1) - 1))}
  end

  @impl true
  def handle_event("recording-trim-reset", %{"id" => id}, socket) do
    id = String.to_integer(id)

    socket =
      update(socket, :recordings, fn recordings ->
        Map.update!(recordings, id, fn recording ->
          Map.put(recording, :trimmed_raw, recording.raw)
        end)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("recording-del", %{"id" => id}, socket) do
    id = String.to_integer(id)

    socket =
      update(socket, :recordings, fn recordings ->
        Map.delete(recordings, id)
      end)

    {:noreply, socket}
  end

  defp ordered_recordings(recordings, recordings_length) do
    (recordings_length - 1)..0
    |> Enum.map(&{&1, Map.get(recordings, &1)})
  end

  defp update_recording_trimmed(socket, id, mapper) do
    id = String.to_integer(id)

    update(socket, :recordings, fn recordings ->
      Map.update!(recordings, id, fn recording ->
        Map.update!(recording, :trimmed_raw, &mapper.(&1))
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
end
