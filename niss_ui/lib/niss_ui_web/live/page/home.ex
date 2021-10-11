defmodule NissUiWeb.Live.Page.Home do
  use NissUiWeb, :surface_view

  def mount(_params, session, socket) do
    ensure_auth_live(session, socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    TODO
    """
  end
end
