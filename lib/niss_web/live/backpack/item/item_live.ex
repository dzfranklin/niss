defmodule NissWeb.Backpack.ItemLive do
  use NissWeb, :live_view
  on_mount NissWeb.RequireAuthLive

  # TODO: System will be totally separate flow, once you add

  def mount(params, session, socket) do
    {:ok, socket}
  end
end
