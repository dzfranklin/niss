defmodule NissUiWeb.EnsureAuth do
  use NissUiWeb, :plug
  alias NissUi.Auth
  alias Phoenix.LiveView

  def init(_params), do: nil

  def call(conn, _params) do
    token = get_session(conn, :auth_token)
    conn = put_session(conn, :remote_ip, Auth.serialize_ip(conn.remote_ip))

    if Auth.allow?(conn.remote_ip, token) do
      conn
      |> assign(:authed?, true)
    else
      conn
      |> put_flash(:error, "Authentication required")
      |> redirect(to: Routes.page_public_path(conn, :index))
      |> halt()
    end
  end

  @doc """
  The route must also be protected with the plug `EnsureAuth`
  """
  def ensure_auth_live(session, socket) do
    # Since the route is also protected with the plug EnsureAuth, we don't need
    # to check in the unconnected render
    if LiveView.connected?(socket) do
      token = Map.get(session, "auth_token")

      if Auth.allow_live?(token) do
        LiveView.assign(socket, :authed?, true)
      else
        raise "Missing auth"
      end
    end
  end
end
