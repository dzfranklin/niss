defmodule NissWeb.PlantsPage do
  @moduledoc """
  Params:
  - `authed?`: `bool`
  - `intl`: `NissWeb.PutIntlLive.Intl`
  """
  use NissWeb, :live_component
  alias Niss.Plants
  alias __MODULE__.CalendarComponent
  alias NissWeb.PlantComponent

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    tz = socket.assigns.intl.tz

    socket =
      assign(socket,
        month_shown: Timex.now(tz) |> Timex.beginning_of_month(),
        plants: Plants.list()
      )

    {:ok, socket}
  end
end
