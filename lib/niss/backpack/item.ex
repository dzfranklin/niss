defmodule Niss.Backpack.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "backpack_items" do
    field :name, :string
    field :weight, :integer
    field :issue, :string
    field :note, :string
    # TODO: image. Volume?

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :weight, :issue, :note])
    |> validate_required([:name])
  end
end
