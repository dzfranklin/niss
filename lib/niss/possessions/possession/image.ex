defmodule Niss.Possessions.Possession.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "possession_images" do
    timestamps()
  end

  @doc false
  def changeset(image \\ %__MODULE__{}, attrs) do
    image
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
