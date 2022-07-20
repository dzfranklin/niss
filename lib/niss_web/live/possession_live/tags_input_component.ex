defmodule NissWeb.PossessionLive.TagsInputComponent do
  use NissWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(options: [], active_option_i: 0)}
  end

  @impl true
  def handle_event("pick-active", _, socket) do
    options = socket.assigns.options

    socket =
      if length(options) == 0 do
        socket
      else
        active_i = socket.assigns.active_option_i
        active = Enum.at(options, active_i)

        socket
        |> update(:selected, &Kernel.++(&1, [active]))
        |> assign(options: [], active_option_i: 0)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("move-active-up", _, socket) do
    max_i = length(socket.assigns.options) - 1

    {:noreply,
     update(socket, :active_option_i, fn old ->
       if old == 0 do
         max_i
       else
         old - 1
       end
     end)}
  end

  @impl true
  def handle_event("move-active-down", _, socket) do
    max_i = length(socket.assigns.options) - 1

    {:noreply,
     update(socket, :active_option_i, fn old ->
       if old == max_i do
         0
       else
         old + 1
       end
     end)}
  end

  @impl true
  def handle_event("change", %{"value" => value}, socket) do
    options =
      if value == "" do
        []
      else
        new = %{new: value, display: value}
        [new | socket.assigns.query.(value)]
      end

    {:noreply, assign(socket, options: options, active_option_i: 0)}
  end

  defp serialize_value(selected) do
    selected
    |> Enum.map(fn
      %{id: id} -> %{id: id}
      %{new: display} -> %{new: display}
    end)
    |> Jason.encode!()
  end
end
