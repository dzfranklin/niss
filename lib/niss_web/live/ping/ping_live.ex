defmodule NissWeb.PingLive do
  use NissWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("ping", %{"n" => n, "at" => pingAt}, socket) do
    {:noreply, push_event(socket, "pong", %{n: n, pingAt: pingAt})}
  end
end
