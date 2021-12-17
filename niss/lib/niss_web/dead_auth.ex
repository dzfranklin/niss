defmodule NissWeb.DeadAuth do
  import Plug.Conn
  alias Phoenix.Controller
  alias NissWeb.Router.Helpers, as: Routes

  def dead_auth(conn, _opts) do
    if get_session(conn, "authed?") do
      conn
    else
      conn
      |> Controller.put_flash(:warn, "Authentication required")
      |> Controller.redirect(to: Routes.auth_path(conn, :index))
      |> halt()
    end
  end
end
