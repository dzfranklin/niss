defmodule Niss.PlantsFixtures do
  @moduledoc """
  Fixtures that create plants structs.

  These fixtures do not modify the database, and are intended to be used with mocks.
  """

  alias Niss.Plants.{Plant, WateringRecord, LightingRecord}
  alias Ecto.Changeset
  def unique_plant_identifier, do: "some identifier#{System.unique_integer([:positive])}"
  def unique_id, do: System.unique_integer([:positive])

  def plant_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      identifier: unique_plant_identifier(),
      timezone: "Etc/UTC",
      lights_on: ~T[14:00:00],
      lights_duration: ~T[23:59:59],
      watering_duration_secs: 42,
      watering_interval_days: 42,
      watering_time: ~T[14:00:00],
      tank_base_area: 1,
      tank_max_depth: 10
    })
    |> Plant.changeset()
    |> Changeset.apply_action!(:insert)
    |> Map.put(:id, Map.get(attrs, :id, unique_id()))
  end

  def watering_record_fixture(plant, attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      plant_id: plant.id,
      duration_secs: 42,
      scheduled?: true,
      at: ~U[2021-12-20 12:00:00.000000Z]
    })
    |> WateringRecord.changeset()
    |> Changeset.apply_action!(:insert)
    |> Map.put(:id, Map.get(attrs, :id, unique_id()))
  end

  def lighting_record_fixture(plant, attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      plant_id: plant.id,
      scheduled?: true,
      on?: true,
      at: ~U[2021-12-20 12:00:00.000000Z]
    })
    |> LightingRecord.changeset()
    |> Changeset.apply_action!(:insert)
    |> Map.put(:id, Map.get(attrs, :id, unique_id()))
  end
end
