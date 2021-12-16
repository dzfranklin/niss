defmodule Niss.Plants.WateringRecord do
  use Niss.Schema
  alias Niss.Plants.Plant

  @type t :: %__MODULE__{}

  schema "plant_watering_records" do
    belongs_to :plant, Plant
    field :duration_secs, :integer
    field :scheduled?, :boolean, default: false
    # Making this usec lets us have faster mock scenarios in tests
    field :at, :utc_datetime_usec

    timestamps()
  end

  @doc false
  def changeset(watering_record \\ %__MODULE__{}, attrs) do
    watering_record
    |> cast(attrs, [:plant_id, :at, :duration_secs, :scheduled?])
    |> validate_required([:plant_id, :at, :duration_secs, :scheduled?])
  end
end
