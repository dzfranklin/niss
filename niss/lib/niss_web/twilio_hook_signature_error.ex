defmodule NissWeb.TwilioHookSignatureError do
  use NissWeb, :controller

  def call(conn, :not_authenticated) do
    conn
    |> put_status(401)
    |> text("Not authenticated\n")
  end

  def call(conn, :bad_request) do
    conn
    |> put_status(400)
    |> text("Bad Request\n")
  end
end
