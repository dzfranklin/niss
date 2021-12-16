defmodule NissWeb.PlantLive.Index do
  use NissWeb, :live_view

  alias Niss.Plants
  alias Niss.Plants.Plant

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :plants, list())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    id = String.to_integer(id)

    socket
    |> assign(:page_title, "Edit Plant")
    |> assign(:plant, Plants.get!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Plant")
    |> assign(:plant, %Plant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Plants")
    |> assign(:plant, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id = String.to_integer(id)
    plant = Plants.get!(id)
    {:ok, _} = Plants.delete(plant)

    {:noreply, assign(socket, :plants, list())}
  end

  defp list do
    Plants.list()
  end
end
