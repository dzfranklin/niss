defmodule NissUiWeb.Auth do
  use NissUiWeb, :controller
  alias NissUi.Auth
  alias Auth.Login

  def login(conn, _params) do
    render(conn, "index.html", change: Login.changeset(%{}))
  end

  def login_post(conn, %{"login" => attrs}) do
    attrs
    |> Login.changeset()
    |> Login.check()
    |> case do
      :ok ->
        token = Auth.mint_token(conn.remote_ip)

        conn
        |> put_session(:auth_token, token)
        |> redirect(to: Routes.page_home_path(conn, :index))

      {:error, change} ->
        render(conn, "index.html", change: change)
    end
  end

  def logout(conn, _params) do
    conn
    |> put_session(:auth_token, nil)
    |> redirect(to: Routes.page_public_path(conn, :index))
  end
end
