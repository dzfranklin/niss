defmodule Niss.Plants.LightingRecord do
  use Niss.Schema
  alias Niss.Plants.Plant

  @type t :: %__MODULE__{}

  schema "plant_lighting_records" do
    belongs_to :plant, Plant
    field :scheduled?, :boolean, default: false
    field :on?, :boolean, default: false
    # Making this usec lets us have faster mock scenarios in tests
    field :at, :utc_datetime_usec

    timestamps()
  end

  @doc false
  def changeset(lighting_record \\ %__MODULE__{}, attrs) do
    lighting_record
    |> cast(attrs, [:plant_id, :at, :on?, :scheduled?])
    |> validate_required([:plant_id, :at, :on?, :scheduled?])
  end
end
