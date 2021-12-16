defmodule Niss.Plants.TankLevelRecord do
  use Niss.Schema
  alias Niss.Plants.Plant

  schema "plants_tank_level_records" do
    belongs_to :plant, Plant
    field :failed?, :boolean, default: false
    # Units in liters
    field :remaining, :float
    field :total, :float
    field :at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(entry \\ %__MODULE__{}, attrs) do
    entry
    |> cast(attrs, [:plant_id, :failed?, :remaining, :total, :at])
    |> validate_required([:plant_id, :failed?, :total, :at])
  end
end
