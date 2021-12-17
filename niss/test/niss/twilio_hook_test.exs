defmodule Niss.TwilioHookTest do
  use Niss.DataCase
  alias Niss.{TwilioHook, Phone, PubSub}
  alias Phone.Text

  test "saves and broadcasts new text" do
    PubSub.subscribe("phone_text:+15558675310")

    # Sample based on <https://www.twilio.com/docs/messaging/guides/webhook-request>
    assert TwilioHook.message_in(%{
             "MessageSid" => "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "SmsSid" => "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "AccountSid" => "ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "MessagingServiceSid" => "MGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "From" => "+14017122661",
             "To" => "+15558675310",
             "Body" => "Ahoy! We can't wait to see what your build.",
             "NumMedia" => "0",
             "FromCity" => "SAN FRANCISCO",
             "FromState" => "CA",
             "FromZip" => "94103",
             "FromCountry" => "US",
             "ToCity" => "SAUSALITO",
             "ToState" => "CA",
             "ToZip" => "94965",
             "ToCountry" => "US"
           }) == nil

    assert [
             %Text{
               message_sid: "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
               to_number: "+15558675310",
               from_number: "+14017122661",
               body: "Ahoy! We can't wait to see what your build.",
               from_city: "SAN FRANCISCO",
               from_state: "CA",
               from_zip: "94103",
               from_country: "US"
             } = new_text
           ] = Phone.list_texts()

    assert_receive {:new, ^new_text}
  end

  test "saves and broadcasts new text without geo params" do
    # The geo params are optional

    PubSub.subscribe("phone_text:+15558675310")

    # Sample based on <https://www.twilio.com/docs/messaging/guides/webhook-request>
    assert TwilioHook.message_in(%{
             "MessageSid" => "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "SmsSid" => "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "AccountSid" => "ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "MessagingServiceSid" => "MGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
             "From" => "+14017122661",
             "To" => "+15558675310",
             "Body" => "Ahoy! We can't wait to see what your build.",
             "NumMedia" => "0"
           }) == nil

    assert [
             %Text{
               message_sid: "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
               to_number: "+15558675310",
               from_number: "+14017122661",
               body: "Ahoy! We can't wait to see what your build.",
               from_city: nil,
               from_state: nil,
               from_zip: nil,
               from_country: nil
             } = new_text
           ] = Phone.list_texts()

    assert_receive {:new, ^new_text}
  end

  test "saves and broadcasts with real world data" do
    PubSub.subscribe("phone_text:+17208072089")

    assert TwilioHook.message_in(%{
             "AccountSid" => "AC5a9ae9ba61802c8d7b3f5facf9d5e6ed",
             "ApiVersion" => "2010-04-01",
             "Body" => "testing",
             "From" => "+17207344134",
             "FromCity" => "",
             "FromCountry" => "US",
             "FromState" => "CO",
             "FromZip" => "",
             "MessageSid" => "SM7bb6438617765a372a12c2e6392d6842",
             "NumMedia" => "0",
             "NumSegments" => "1",
             "SmsMessageSid" => "SM7bb6438617765a372a12c2e6392d6842",
             "SmsSid" => "SM7bb6438617765a372a12c2e6392d6842",
             "SmsStatus" => "received",
             "To" => "+17208072089",
             "ToCity" => "",
             "ToCountry" => "US",
             "ToState" => "CO",
             "ToZip" => ""
           }) == nil

    assert [
             %Text{
               message_sid: "SM7bb6438617765a372a12c2e6392d6842",
               to_number: "+17208072089",
               from_number: "+17207344134",
               body: "testing",
               from_city: nil,
               from_state: "CO",
               from_zip: nil,
               from_country: "US"
             } = new_text
           ] = Phone.list_texts()

    assert_receive {:new, ^new_text}
  end
end
