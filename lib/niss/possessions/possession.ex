defmodule Niss.Possessions.Possession do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__.Image

  schema "possessions" do
    field :count, :integer
    field :description, :string
    field :name, :string
    belongs_to :image, Image, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(possession, attrs) do
    possession
    |> cast(attrs, [:name, :count, :description, :image_id])
    |> validate_required([:name, :count])
  end
end
