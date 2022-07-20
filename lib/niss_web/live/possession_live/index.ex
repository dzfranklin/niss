defmodule NissWeb.PossessionLive.Index do
  use NissWeb, :live_view

  import NissWeb.PossessionLive.Helpers
  alias Niss.Possessions
  alias Niss.Possessions.Possession

  @impl true
  def mount(_params, session, socket) do
    socket = ensure_authed(socket, session)
    {:ok, assign(socket, :possessions, list_possessions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Possession")
    |> assign(:possession, Possessions.get_possession!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Possession")
    |> assign(:possession, %Possession{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Possessions")
    |> assign(:possession, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    possession = Possessions.get_possession!(id)
    {:ok, _} = Possessions.delete_possession(possession)

    {:noreply, assign(socket, :possessions, list_possessions())}
  end

  defp list_possessions do
    Possessions.list_possessions()
  end
end
