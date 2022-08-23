defmodule NissWeb.PossessionLive.FormLive do
  use NissWeb, :live_view

  import NissWeb.PossessionLive.Helpers
  alias NissWeb.PossessionLive.TagsInputComponent
  alias Niss.Possessions
  alias NissWeb.PairLive.Helpers, as: Pair

  @impl true
  def mount(_params, session, socket) do
    prim = session.session_id
    if connected?(socket) do
      Pair.subscribe(prim)
      if Pair.connected? # TODOO Hun
      Pair.request_pic(prim)
    end

    possession_id = Map.fetch!(session, "possession_id")
    possession = if is_nil(possession_id) do
      %Possessions.Possession{}
    else
      Possessions.get_possession!(possession_id)
    end
    changeset = Possessions.change_possession(possession)

    {:ok,
     socket
     |> assign(
       prim: prim,
       title: Map.fetch!(session, "title"),
       action: Map.fetch!(session, "action"),
       return_to: Map.fetch!(session, "return_to"),
       possession: possession,
       changeset: changeset,
       uploaded_files: [],
       selected_tags: [
         %{id: 3, display: "Tag 3"},
         %{id: 1, display: "Tag 1"}
       ]
     )
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
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
      {:ok, possession} ->
        save_image(socket, possession)

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
      {:ok, possession} ->
        save_image(socket, possession)

        {:noreply,
         socket
         |> put_flash(:info, "Possession created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_image(socket, possession) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      Possessions.set_image!(possession, path)
    end)
  end

  defp query_tag(partial) do
    [
      %{id: 42, display: partial <> "_"},
      %{id: 43, display: "_" <> partial <> "_"}
    ]
  end
end
