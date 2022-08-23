defmodule NissWeb.SessionIdPlug do
  import Plug.Conn

  def maybe_assign_session_id(conn, _opts) do
    if is_nil(get_session(conn, :session_id)) do
      id = Ecto.UUID.generate()
      put_session(conn, :session_id, id)
    else
      conn
    end
  end
end
