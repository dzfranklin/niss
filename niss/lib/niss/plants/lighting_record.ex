defmodule Niss.Plants.LightingRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Niss.Plants.Plant

  @type t :: %__MODULE__{}

  schema "plant_lighting_records" do
    belongs_to :plant, Plant
    field :scheduled?, :boolean, default: false
    field :status, :boolean, default: false
    field :time, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(lighting_record, attrs) do
    lighting_record
    |> cast(attrs, [:time, :status, :scheduled?])
    |> validate_required([:time, :status, :scheduled?])
  end
end
