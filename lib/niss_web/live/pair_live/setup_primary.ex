defmodule NissWeb.PairLive.SetupPrimary do
  use NissWeb, :live_view

  alias NissWeb.PairLive.Helpers, as: Pair
  require Logger

  @impl true
  def mount(_params, %{"session_id" => session_id} = session, socket) do
    socket = ensure_authed(socket, session)

    url = Routes.pair_companion_url(socket, :show, session_id)
    qr =url
    |> QRCode.QR.create!()
    |> QRCode.Svg.create()

    if connected?(socket) do
      Pair.subscribe(session_id)
    end

    {:ok, assign(socket, prim: session_id, url: url, qr: qr)}
  end

  @impl true
  def handle_info({:pair, {:connect_request, comp}}, socket) do
    prim = socket.assigns.prim
    Pair.broadcast!(prim, {:connect_accept, comp})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:pair, msg}, socket) do
    Logger.debug("Ignoring msg #{inspect(msg)}")
    {:noreply, socket}
  end
end
