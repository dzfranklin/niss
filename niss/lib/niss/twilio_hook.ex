defmodule Niss.TwilioHook do
  @moduledoc """
  Handles ingesting data send by Twilio to our webhooks
  """
  require Logger
  alias Niss.Phone

  @spec message_in(map()) :: nil
  def message_in(
        %{
          # A 34 character unique identifier for the message.
          "MessageSid" => message_sid,
          # The phone number that sent this message. Ex `+14017122661`.
          "From" => from_number,
          "To" => to_number,
          # The text body of the message. Up to 1600 characters long.
          "Body" => body,
          # The number of media items associated with your message
          "NumMedia" => num_media
        } = params
      ) do
    num_media = String.to_integer(num_media)

    # Optional params
    from_city = Map.get(params, "FromCity")
    from_state = Map.get(params, "FromState")
    from_zip = Map.get(params, "FromZip")
    from_country = Map.get(params, "FromCountry")

    if num_media > 0 do
      Logger.warn("Unhandled media")
    end

    {:ok, _text} =
      Phone.create_text(%{
        message_sid: message_sid,
        from_number: from_number,
        to_number: to_number,
        body: body,
        from_city: from_city,
        from_state: from_state,
        from_zip: from_zip,
        from_country: from_country
      })

    nil
  end
end
