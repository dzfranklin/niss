defmodule Niss.PhoneTest do
  use Niss.DataCase
  alias Niss.Phone
  alias Niss.PubSub

  describe "phone_texts" do
    alias Niss.Phone.Text

    import Niss.PhoneFixtures

    @invalid_attrs %{
      body: nil,
      from_city: nil,
      from_country: nil,
      from_number: nil,
      from_state: nil,
      from_zip: nil,
      message_sid: nil,
      to_number: nil
    }

    test "list_texts/0 returns all phone_texts" do
      text = text_fixture()
      assert Phone.list_texts() == [text]
    end

    test "get_text!/1 returns the text with given id" do
      text = text_fixture()
      assert Phone.get_text!(text.id) == text
    end

    test "create_text/1 with valid data creates a text and broadcasts it" do
      valid_attrs = %{
        body: "some body",
        from_city: "some from_city",
        from_country: "some from_country",
        from_number: "some from_number",
        from_state: "some from_state",
        from_zip: "some from_zip",
        message_sid: "some message_sid",
        to_number: "some to_number"
      }

      PubSub.subscribe("phone_text:some to_number")

      assert {:ok, %Text{} = text} = Phone.create_text(valid_attrs)
      assert text.body == "some body"
      assert text.from_city == "some from_city"
      assert text.from_country == "some from_country"
      assert text.from_number == "some from_number"
      assert text.from_state == "some from_state"
      assert text.from_zip == "some from_zip"
      assert text.message_sid == "some message_sid"
      assert text.to_number == "some to_number"

      assert_receive {:new, ^text}
    end

    test "create_text/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Phone.create_text(@invalid_attrs)
    end

    test "delete_text/1 deletes the text" do
      text = text_fixture()
      assert {:ok, %Text{}} = Phone.delete_text(text)
      assert_raise Ecto.NoResultsError, fn -> Phone.get_text!(text.id) end
    end
  end
end
