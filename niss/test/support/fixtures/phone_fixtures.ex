defmodule Niss.PhoneFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niss.Phone` context.
  """

  @doc """
  Generate a text.
  """
  def text_fixture(attrs \\ %{}) do
    {:ok, text} =
      attrs
      |> Enum.into(%{
        body: "some body",
        from_city: "some from_city",
        from_country: "some from_country",
        from_number: "some from_number",
        from_state: "some from_state",
        from_zip: "some from_zip",
        message_sid: "some message_sid",
        to_number: "some to_number"
      })
      |> Niss.Phone.create_text()

    text
  end
end
