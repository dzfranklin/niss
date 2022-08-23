defmodule NissWeb.PairLive.Companion do
  use NissWeb, :live_view

  require Logger
  alias NissWeb.PairLive.Helpers, as: Pair

  # NOTE: We don't login

  @impl true
  def mount(%{"prim" => prim}, _session, socket) do
    if not connected?(socket) do
      {:ok, socket}
    else
      comp = Ecto.UUID.generate()
      socket = assign(socket, prim: prim, comp: comp, status: :pairing)

      Pair.broadcast!(prim, {:connect_request, comp})
      Pair.subscribe(prim)
      timeout_timer = Process.send_after(self(), :timeout, 1_000)


      {:ok, assign(socket, pair_timeout_timer: timeout_timer)}
    end
  end

  @impl true
  def handle_info({:pair, {:connect_accept, accepted}}, socket) do
    socket = if accepted == socket.assigns.comp do
      socket
      |> update(:pair_timeout_timer, fn timer ->
        Process.cancel_timer(timer)
        nil
      end)
      |> assign(status: :ready)
    else
      socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:timeout, socket) do
    Pair.unsubscribe(socket.assigns.prim)
    {:noreply, assign(socket, status: :failed)}
  end
end
