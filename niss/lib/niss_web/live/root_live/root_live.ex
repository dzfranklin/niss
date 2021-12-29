defmodule NissWeb.RootLive do
  use NissWeb, :live_view

  on_mount {NissWeb.LiveAuth, :optional}
  on_mount NissWeb.PutIntl

  @impl true
  def handle_event("dismiss-flash", %{"key" => key}, socket) do
    key =
      case key do
        "info" -> :info
        "warn" -> :warn
        "danger" -> :danger
      end

    {:noreply, clear_flash(socket, key)}
  end

  def flashes(assigns) do
    ~H"""
    <%= for key <- [:info, :warn, :danger] do %>
      <%= if !is_nil(live_flash(@flash, key)) do %>
      <button id={key} class={"alert-#{key} block w-full text-left"}
          phx-click={
            JS.hide()
            |> JS.push("dismiss-flash", value: %{key: Atom.to_string(key)})
          }
          type="button" role="alert"
      >
          <%= live_flash(@flash, key) %>
      </button>
      <% end %>
    <% end %>
    """
  end
end
