defmodule NissWeb.PossessionLive.Show do
  use NissWeb, :live_view

  alias Niss.Possessions

  @impl true
  def mount(_params, session, socket) do
    socket = ensure_authed(socket, session)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:possession, Possessions.get_possession!(id))}
  end

  defp page_title(:show), do: "Show Possession"
  defp page_title(:edit), do: "Edit Possession"
end
