defmodule NissWeb.PlantLive.FormComponent do
  use NissWeb, :live_component
  alias Timex.Duration
  alias Niss.{Now, Plants}

  @impl true
  def update(%{plant: plant} = assigns, socket) do
    changeset = Plants.change(plant)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"plant" => plant_params}, socket) do
    changeset =
      socket.assigns.plant
      |> Plants.change(plant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"plant" => plant_params}, socket) do
    save_plant(socket, socket.assigns.action, plant_params)
  end

  defp save_plant(socket, :edit, plant_params) do
    case Plants.update(socket.assigns.plant, plant_params) do
      {:ok, _plant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plant updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_plant(socket, :new, plant_params) do
    case Plants.create(plant_params) do
      {:ok, _plant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plant created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp lights_off(change) do
    if change.valid? do
      timezone = Ecto.Changeset.fetch_field!(change, :timezone)
      on = Ecto.Changeset.fetch_field!(change, :lights_on)
      duration = Ecto.Changeset.fetch_field!(change, :lights_duration)

      if !is_nil(timezone) && !is_nil(on) && !is_nil(duration) do
        start_today =
          Now.now_in!(timezone)
          |> Timex.beginning_of_day()

        off_at =
          start_today
          |> Timex.add(Duration.from_time(on))
          |> Timex.add(Duration.from_time(duration))

        off = Timex.format!(off_at, "{h24}:{m}")

        if Timex.diff(off_at, start_today, :hour) > 23 do
          "#{off} tomorrow"
        else
          off
        end
      end
    end
  end
end
