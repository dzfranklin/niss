defmodule NissWeb.PossessionLive.ImageCompanion.Show do
  use NissWeb, :live_view

  alias Niss.Possessions.ImageCompanion.Matcher
  require Logger

  # NOTE: We don't require auth

  # TODO: This should follow the whole session around and do all their uploads

  @impl true
  def mount(%{"id" => relship_id}, session, socket) do
    if connected?(socket) do
      {:ok, prim} = Matcher.register_companion(relship_id)

      {:ok,
       socket
       |> assign_current_user(session)
       |> assign(prim: prim)
       |> allow_upload(:image,
         accept: ~w(.jpg .jpeg .png),
         max_entries: 1,
         auto_upload: true,
         progress: &handle_progress/3
       )}
    else
      {:ok, socket}
    end
  end

  def handle_progress(:image, %{done?: true} = entry, socket) do
    Logger.warn("image done")
    handle_upload(socket, entry)
  end

  def handle_progress(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("change", _, socket) do
    Logger.warn("change")
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", _, socket) do
    Logger.warn("submit")
    # We only have one entry, and it's guaranteed completed before submit called
    {[entry], []} = uploaded_entries(socket, :image)
    handle_upload(socket, entry)
  end

  def handle_upload(socket, entry) do
    prim = socket.assigns.prim

    consume_uploaded_entry(socket, entry, fn %{path: path} ->
      Logger.info("Companion sending to #{inspect(prim)}")
      send(prim, {:companion_uploaded_image, path})
      {:ok, nil}
    end)

    {:noreply, socket}
  end
end
