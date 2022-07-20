defmodule NissWeb.PossessionLive.FormComponent do
  use NissWeb, :live_component

  alias Niss.Possessions

  @impl true
  def update(%{possession: possession} = assigns, socket) do
    changeset = Possessions.change_possession(possession)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"possession" => possession_params}, socket) do
    changeset =
      socket.assigns.possession
      |> Possessions.change_possession(possession_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"possession" => possession_params}, socket) do
    save_possession(socket, socket.assigns.action, possession_params)
  end

  defp save_possession(socket, :edit, possession_params) do
    case Possessions.update_possession(socket.assigns.possession, possession_params) do
      {:ok, _possession} ->
        {:noreply,
         socket
         |> put_flash(:info, "Possession updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_possession(socket, :new, possession_params) do
    case Possessions.create_possession(possession_params) do
      {:ok, _possession} ->
        {:noreply,
         socket
         |> put_flash(:info, "Possession created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
