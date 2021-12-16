defmodule Niss.Plants.Plant do
  @moduledoc """
  Represents a Plant and the associated information about how to care for it.

  All times UTC.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @type id :: integer()

  schema "plants" do
    field :identifier, :string
    field :lights_on, :time
    field :lights_duration, :time
    field :watering_duration_secs, :integer
    field :watering_interval_days, :integer
    field :watering_time, :time

    timestamps()
  end

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, [
      :identifier,
      :watering_interval_days,
      :watering_duration_secs,
      :watering_time,
      :lights_on,
      :lights_duration
    ])
    |> validate_required([
      :identifier,
      :watering_interval_days,
      :watering_duration_secs,
      :watering_time,
      :lights_on,
      :lights_duration
    ])
    |> unique_constraint(:identifier)
  end
end
