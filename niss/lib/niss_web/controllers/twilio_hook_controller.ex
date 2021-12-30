defmodule NissWeb.TwilioHookController do
  use NissWeb, :controller
  require Logger

  # Configured as "A mesage comes in" webhook
  def message_in(conn, params) do
    Logger.warn("Received message in from twilio:\n#{inspect(params, pretty: true)}")
    Niss.TwilioHook.message_in(params)

    conn
    |> put_status(:ok)
    |> put_resp_content_type("application/xml")
    |> text("<Response></Response>\n")
  end
end
