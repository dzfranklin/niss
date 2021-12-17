defmodule NissWeb.AuthController do
  use NissWeb, :controller
  alias Niss.Auth

  def index(conn, _params) do
    render(conn, "index.html", authed?: get_session(conn, "authed?"))
  end

  def do_auth(conn, %{"form" => %{"pass" => pass}}) do
    if Auth.valid?(pass) do
      conn
      |> put_session("authed?", true)
    else
      conn
      |> put_session("authed?", false)
      |> put_flash(:error, "Authentication failed")
    end
    |> redirect(to: Routes.auth_path(conn, :index))
  end

  def do_logout(conn, _params) do
    conn
    |> put_session("authed?", false)
    |> redirect(to: Routes.auth_path(conn, :index))
  end
end
