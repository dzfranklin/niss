defmodule NissWeb.PossessionLive.FormComponent do
  use NissWeb, :live_component

  import NissWeb.PossessionLive.Helpers
  alias NissWeb.PossessionLive.TagsInputComponent
  alias Niss.Possessions
  alias Possessions.ImageCompanion
  require Logger

  @impl true
  def update(%{possession: possession} = assigns, socket) do
    changeset = Possessions.change_possession(possession)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset: changeset,
       selected_tags: [
         %{id: 3, display: "Tag 3"},
         %{id: 1, display: "Tag 1"}
       ],
       img_companion_flow: nil
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

  @impl true
  def handle_event("save", %{"possession" => possession_params}, socket) do
    save_possession(socket, socket.assigns.action, possession_params)
  end

  @impl true
  def handle_event("init-companion-flow", _, socket) do
    {:ok, relship_id} = ImageCompanion.Matcher.register_primary()
    Logger.info("primary pid #{inspect(self())}")

    url = Routes.possession_image_companion_show_url(socket, :show, relship_id)

    qr =
      url
      |> QRCode.QR.create!()
      |> QRCode.Svg.create()

    {:noreply, assign(socket, img_companion_flow: {:pairing, {url, qr}})}
  end

  def handle_info({:companion_uploaded_image, path}, socket) do
    Logger.info("Got image #{inspect(path)}")
    {:noreply, socket}
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
