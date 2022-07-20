defmodule NissWeb.HomeLive.Index do
  use NissWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = ensure_authed(socket, session)
    {:ok, socket}
  end
end
