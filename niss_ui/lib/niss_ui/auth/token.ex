defmodule NissUi.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @token_size 32

  schema "auth_tokens" do
    field :token, :binary, required: true
    field :created_by_ip, :string

    timestamps()
  end

  @spec generate_token :: binary()
  def generate_token do
    :crypto.strong_rand_bytes(@token_size)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(token \\ %__MODULE__{}, attrs) do
    token
    |> cast(attrs, [:token])
    |> validate_required([:token])
  end
end
