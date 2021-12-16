defmodule Niss.PlantsTest do
  use Niss.DataCase

  alias Niss.Plants
  alias Niss.Plants.Plant
  import Niss.PlantsFixtures

  describe "next_watering/1" do
    test "works if never watered" do
      plant =
        plant_fixture(%{
          watering_interval_days: 2,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 12
        })

      now = ~U[2021-12-16 00:42:42Z]
      assert Plants.next_watering(plant, now) == {~U[2021-12-18 02:00:01Z], 12}
    end

    test "works if already watered" do
      plant =
        plant_fixture(%{
          watering_interval_days: 3,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 13
        })

      _old_record = watering_record_fixture(%{start: ~U[2021-12-10 00:00:00Z]})
      _prev_record = watering_record_fixture(%{start: ~U[2021-12-11 00:42:00Z]})

      assert Plants.next_watering(plant) == {~U[2021-12-14 02:00:01Z], 13}
    end
  end

  describe "last_scheduled_watering/1" do
    test "returns nil if no record" do
      plant = plant_fixture()
      assert Plants.last_scheduled_watering(plant) == nil
    end

    test "returns most recent scheduled record if records" do
      plant = plant_fixture()

      _old_record =
        watering_record_fixture(plant, %{
          start: ~U[2021-12-16 00:00:00Z],
          scheduled?: true
        })

      new_record =
        water_record_fixture(plant, %{
          start: ~U[2021-12-17 00:00:00Z],
          scheduled?: true
        })

      _ignored_unscheduled_record =
        water_record_fixture(plant, %{
          start: ~U[2021-12-18 00:00:00Z],
          scheduled?: false
        })

      assert Plants.last_scheduled_watering(plant) == new_record
    end
  end

  @invalid_attrs %{
    identifier: nil,
    lights_off: nil,
    lights_on: nil,
    watering_duration_secs: nil,
    watering_interval_days: nil,
    watering_time: nil
  }

  test "list/0 returns all plants" do
    plant = plant_fixture()
    assert Plants.list() == [plant]
  end

  test "get!/1 returns the plant with given id" do
    plant = plant_fixture()
    assert Plants.get!(plant.id) == plant
  end

  test "create/1 with valid data creates a plant" do
    valid_attrs = %{
      identifier: "some identifier",
      lights_off: ~T[14:00:00],
      lights_on: ~T[14:00:00],
      watering_duration_secs: 42,
      watering_interval_days: 42,
      watering_time: ~T[14:00:00]
    }

    assert {:ok, %Plant{} = plant} = Plants.create(valid_attrs)
    assert plant.identifier == "some identifier"
    assert plant.lights_off == ~T[14:00:00]
    assert plant.lights_on == ~T[14:00:00]
    assert plant.watering_duration_secs == 42
    assert plant.watering_interval_days == 42
    assert plant.watering_time == ~T[14:00:00]
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Plants.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the plant" do
    plant = plant_fixture()

    update_attrs = %{
      identifier: "some updated identifier",
      lights_off: ~T[15:01:01],
      lights_on: ~T[15:01:01],
      watering_duration_secs: 43,
      watering_interval_days: 43,
      watering_time: ~T[15:01:01]
    }

    assert {:ok, %Plant{} = plant} = Plants.update(plant, update_attrs)
    assert plant.identifier == "some updated identifier"
    assert plant.lights_off == ~T[15:01:01]
    assert plant.lights_on == ~T[15:01:01]
    assert plant.watering_duration_secs == 43
    assert plant.watering_interval_days == 43
    assert plant.watering_time == ~T[15:01:01]
  end

  test "update/2 with invalid data returns error changeset" do
    plant = plant_fixture()
    assert {:error, %Ecto.Changeset{}} = Plants.update(plant, @invalid_attrs)
    assert plant == Plants.get!(plant.id)
  end

  test "delete/1 deletes the plant" do
    plant = plant_fixture()
    assert {:ok, %Plant{}} = Plants.delete(plant)
    assert_raise Ecto.NoResultsError, fn -> Plants.get!(plant.id) end
  end

  test "change/1 returns a plant changeset" do
    plant = plant_fixture()
    assert %Ecto.Changeset{} = Plants.change(plant)
  end
end
