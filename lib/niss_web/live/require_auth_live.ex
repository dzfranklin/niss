defmodule NissWeb.RequireAuthLive do
  import Phoenix.LiveView
  import NissWeb.LiveHelpers
  alias NissWeb.Endpoint
  alias NissWeb.Router.Helpers, as: Router

  def on_mount(:default, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if is_nil(socket.assigns.current_user) do
      {:halt, redirect(socket, to: Router.user_session_path(Endpoint, :new))}
    else
      {:cont, socket}
    end
  end
end
