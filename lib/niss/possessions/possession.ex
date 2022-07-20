defmodule Niss.Possessions.Possession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "possessions" do
    field :count, :integer
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(possession, attrs) do
    possession
    |> cast(attrs, [:name, :count, :description])
    |> validate_required([:name, :count])
  end
end
