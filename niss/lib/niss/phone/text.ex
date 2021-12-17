defmodule Niss.Phone.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "phone_texts" do
    # Required
    field :message_sid, :string
    field :to_number, :string
    field :from_number, :string
    field :body, :string

    # Optional
    field :from_city, :string
    field :from_state, :string
    field :from_zip, :string
    field :from_country, :string

    timestamps()
  end

  @doc false
  def changeset(text \\ %__MODULE__{}, attrs) do
    text
    |> cast(attrs, [
      :message_sid,
      :from_number,
      :to_number,
      :body,
      :from_city,
      :from_state,
      :from_zip,
      :from_country
    ])
    |> validate_required([
      :message_sid,
      :from_number,
      :to_number,
      :body
    ])
    |> unique_constraint(:message_sid)
  end
end
