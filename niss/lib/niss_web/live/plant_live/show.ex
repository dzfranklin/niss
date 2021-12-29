defmodule NissWeb.PlantLive.Show do
  use NissWeb, :live_view

  alias Niss.Plants

  on_mount NissWeb.LiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    id = String.to_integer(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:plant, Plants.get!(id))}
  end

  defp page_title(:show), do: "Show Plant"
  defp page_title(:edit), do: "Edit Plant"
end
