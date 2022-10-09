defmodule Niss.Backpack.System do
  use Ecto.Schema
  import Ecto.Changeset
  alias Niss.Backpack.Item

  schema "backpack_systems" do
    field :name, :string
    has_many :item, Item

    timestamps()
  end

  @doc false
  def changeset(system, attrs) do
    system
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
