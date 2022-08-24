defmodule NissWeb.HomeLive do
  use NissWeb, :live_view
  on_mount NissWeb.RequireAuthLive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
