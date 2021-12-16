defmodule Niss.Plants.Plant do
  @moduledoc """
  Represents a Plant and the associated information about how to care for it.

  All times UTC.
  """
  use Niss.Schema
  alias Timex.Timezone

  @type t :: %__MODULE__{}
  @type id :: integer()

  schema "plants" do
    # This is trusted as an atom
    field :identifier, :string
    field :timezone, :string
    # In timezone
    field :lights_on, :time
    field :lights_duration, :time
    field :watering_interval_days, :integer
    # In timezone
    field :watering_time, :time
    field :watering_duration_secs, :integer
    # Unit is square meters
    field :tank_base_area, :float
    field :tank_max_depth, :float

    timestamps()
  end

  @doc false
  def changeset(plant \\ %__MODULE__{}, attrs) do
    plant
    |> cast(attrs, [
      :identifier,
      :timezone,
      :watering_interval_days,
      :watering_duration_secs,
      :watering_time,
      :lights_on,
      :lights_duration,
      :tank_base_area,
      :tank_max_depth
    ])
    |> validate_required([
      :identifier,
      :timezone,
      :watering_interval_days,
      :watering_duration_secs,
      :watering_time,
      :lights_on,
      :lights_duration,
      :tank_base_area,
      :tank_max_depth
    ])
    |> validate_timezone()
    |> unique_constraint(:identifier)
  end

  defp validate_timezone(change) do
    tz = fetch_field!(change, :timezone)

    if is_nil(tz) do
      change
    else
      if Timezone.exists?(tz) do
        change
      else
        add_error(change, :timezone, "does not exist")
      end
    end
  end
end
