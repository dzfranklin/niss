defmodule Niss.PlantsImplTest do
  use Niss.DataCase, async: true, mock: true
  import ExUnit.CaptureLog
  alias Timex.Duration
  import Niss.PlantsFixtures
  alias Niss.{Now, Repo}
  alias Niss.Plants.Impl
  alias Niss.Plants.{Plant, LightingRecord, WateringRecord, TankLevelRecord}

  setup do
    stub(Niss.Now.MockImpl, :utc_now, fn -> ~U[2021-12-16 14:42:42.000000Z] end)
    :ok
  end

  describe "tank_level/1" do
    test "records nil if unrecorded" do
      plant = inserted_plant_fixture()
      assert Impl.tank_level(plant) == nil
    end

    test "returns record if recorded, even if failed" do
      plant = inserted_plant_fixture()

      _record =
        inserted_tank_level_record_fixture(plant, %{
          failed?: true,
          total: 15.0
        })

      assert %TankLevelRecord{} = record = Impl.tank_level(plant)
      assert record.failed?
      assert record.total == 15.0
    end
  end

  describe "create_tank_level_record/1" do
    test "can save without remaining" do
      plant = inserted_plant_fixture()

      assert {:ok, record} =
               Impl.create_tank_level_record(%{
                 plant_id: plant.id,
                 failed?: false,
                 remaining: nil,
                 total: 10,
                 at: Now.utc_now()
               })

      assert record.plant_id == plant.id
      assert record.failed? == false
      assert record.remaining == nil
      assert record.total == 10
      assert record.at == ~U[2021-12-16 14:42:42Z]
    end
  end

  describe "execute!/1" do
    test "lighting" do
      plant = inserted_plant_fixture(%{identifier: "lime"})
      record = lighting_record_fixture(plant, %{on?: true, at: Now.utc_now()})

      expect(Niss.Local.MockImpl, :set_light!, fn :lime, true -> nil end)
      assert Repo.get(LightingRecord, record.id) == nil
      Impl.execute!(record)
      assert Repo.get(LightingRecord, record.id) != nil
    end

    test "watering" do
      plant = inserted_plant_fixture(%{identifier: "chillies"})
      record = watering_record_fixture(plant, %{duration_secs: 10, at: Now.utc_now()})

      expect(Niss.Local.MockImpl, :pump_for!, fn :chillies, 10 -> nil end)
      assert Repo.get(WateringRecord, record.id) == nil
      Impl.execute!(record)
      assert Repo.get(WateringRecord, record.id) != nil
    end

    test "works if at in future, but warns" do
      plant = inserted_plant_fixture()
      now_record = watering_record_fixture(plant, %{at: Now.utc_now()})
      future = Timex.add(Now.utc_now(), Duration.from_minutes(30))
      future_record = watering_record_fixture(plant, %{at: future})

      stub(Niss.Local.MockImpl, :pump_for!, fn _name, _secs -> nil end)

      assert capture_log([level: :warn], fn -> Impl.execute!(now_record) end) == ""

      assert capture_log([level: :warn], fn -> Impl.execute!(future_record) end) =~
               "at not near now. executing anyway"
    end
  end

  describe "scheduled_lighting/2" do
    test "has correct plant_id and scheduled?" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting(plant)
      assert record.scheduled?
      assert record.plant_id == plant.id
    end

    test "works if no records" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting(plant)
      assert record.on?
      assert record.at == ~U[2021-12-16 13:00:01.000000Z]
    end

    test "works with no missed" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      _old =
        inserted_lighting_record_fixture(plant, %{
          scheduled?: true,
          on?: true,
          at: ~U[2021-12-15 14:00:01.000000Z]
        })

      _prev =
        inserted_lighting_record_fixture(plant, %{
          scheduled?: true,
          on?: false,
          at: ~U[2021-12-15 15:00:02.000000Z]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting(plant)
      assert record.on?
      assert record.at == ~U[2021-12-16 13:00:01.000000Z]
    end

    test "skips all but last missed when last missed is off" do
      plant =
        inserted_plant_fixture(%{
          # After now
          lights_on: ~T[20:00:01],
          lights_duration: ~T[01:00:00]
        })

      _old =
        inserted_lighting_record_fixture(plant, %{
          scheduled?: true,
          on?: true,
          at: ~U[2021-12-13 02:00:01.000000Z]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting(plant)
      # Missed off on 14th, on & off 14th, 15th. Today is 16th, hasn't missed yet
      assert record.at == ~U[2021-12-15 20:00:01.000000Z]
      assert !record.on?
    end

    test "skips all but last missed when last missed is on" do
      plant =
        inserted_plant_fixture(%{
          # After now
          lights_on: ~T[16:00:00],
          lights_duration: ~T[00:30:00]
        })

      _old =
        inserted_lighting_record_fixture(plant, %{
          scheduled?: true,
          on?: false,
          at: ~U[2021-12-15 21:00:01.000000Z]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting(plant)
      # Today is 16th, have missed on but not off
      assert record.at == ~U[2021-12-16 15:00:00.000000Z]
      assert record.on?
    end
  end

  describe "scheduled_lighting_after/3" do
    test "has correct plant_id and scheduled?" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting_after(plant, nil, Now.utc_now())
      assert record.scheduled?
      assert record.plant_id == plant.id
    end

    test "works if no records and on is in the past" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting_after(plant, nil, Now.utc_now())
      assert record.on?
      assert record.at == ~U[2021-12-16 13:00:01.000000Z]
    end

    test "works if no records and on is in the future" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      assert %LightingRecord{} = record = Impl.scheduled_lighting_after(plant, nil, Now.utc_now())
      assert record.on?
      assert record.at == ~U[2021-12-16 13:00:01.000000Z]
    end

    test "works if prev is an on" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      prev =
        inserted_lighting_record_fixture(plant, %{
          on?: true,
          at: ~U[2021-12-15 13:00:01.000000Z]
        })

      assert %LightingRecord{} =
               record = Impl.scheduled_lighting_after(plant, prev, Now.utc_now())

      assert !record.on?
      assert record.at == ~U[2021-12-16 13:00:00.000000Z]
    end

    test "works if prev is an off" do
      plant =
        inserted_plant_fixture(%{
          lights_on: ~T[14:00:01],
          lights_duration: ~T[23:59:59]
        })

      prev =
        inserted_lighting_record_fixture(plant, %{
          on?: false,
          at: ~U[2021-12-15 14:00:00.000000Z]
        })

      assert %LightingRecord{} =
               record = Impl.scheduled_lighting_after(plant, prev, Now.utc_now())

      assert record.on?
      assert record.at == ~U[2021-12-16 13:00:01.000000Z]
    end
  end

  describe "scheduled_watering/2" do
    test "has correct plant_id, duration, and scheduled?" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 2,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 12
        })

      assert %WateringRecord{} = record = Impl.scheduled_watering(plant)
      assert record.plant_id == plant.id
      assert record.scheduled?
      assert record.duration_secs == plant.watering_duration_secs
    end

    test "works if never watered" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 2,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 12
        })

      assert %WateringRecord{} = record = Impl.scheduled_watering(plant)
      assert record.at == ~U[2021-12-18 01:00:01.000000Z]
    end

    test "works with no missed" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 2,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 12
        })

      _prev =
        inserted_watering_record_fixture(plant, %{
          scheduled?: true,
          at: ~U[2021-12-18 02:00:01.000000Z]
        })

      assert %WateringRecord{} = record = Impl.scheduled_watering(plant)
      assert record.at == ~U[2021-12-20 01:00:01.000000Z]
    end

    test "skips all but last missed" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 2,
          # After now
          watering_time: ~T[16:00:01],
          watering_duration_secs: 12
        })

      _prev =
        inserted_watering_record_fixture(plant, %{
          scheduled?: true,
          at: ~U[2021-12-08 02:00:01.000000Z]
        })

      assert %WateringRecord{} = record = Impl.scheduled_watering(plant)
      # Missed on 10th, 12th, 14th. Today is 16th, hasn't missed yet
      assert record.at == ~U[2021-12-14 15:00:01.000000Z]
    end
  end

  describe "scheduled_watering_after/3" do
    test "has correct plant_id, duration, and scheduled?" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 2,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 12
        })

      assert %WateringRecord{} = record = Impl.scheduled_watering_after(plant, nil, Now.utc_now())

      assert record.plant_id == plant.id
      assert record.scheduled?
      assert record.duration_secs == plant.watering_duration_secs
    end

    test "works if never watered" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 2,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 12
        })

      assert %WateringRecord{} = record = Impl.scheduled_watering_after(plant, nil, Now.utc_now())
      assert record.at == ~U[2021-12-18 01:00:01.000000Z]
    end

    test "works if already watered" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 3,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 13
        })

      _old =
        inserted_watering_record_fixture(plant, %{
          scheduled?: true,
          at: ~U[2021-12-10 00:00:00.000000Z]
        })

      prev =
        inserted_watering_record_fixture(plant, %{
          scheduled?: true,
          at: ~U[2021-12-15 00:42:00.000000Z]
        })

      assert record =
               %WateringRecord{} = Impl.scheduled_watering_after(plant, prev, Now.utc_now())

      assert record.at == ~U[2021-12-18 01:00:01.000000Z]
    end

    test "returns a time in the past if overdue" do
      plant =
        inserted_plant_fixture(%{
          watering_interval_days: 3,
          watering_time: ~T[02:00:01],
          watering_duration_secs: 13
        })

      prev =
        inserted_watering_record_fixture(plant, %{
          scheduled?: true,
          at: ~U[2021-12-10 00:00:00.000000Z]
        })

      assert record =
               %WateringRecord{} = Impl.scheduled_watering_after(plant, prev, Now.utc_now())

      assert record.at == ~U[2021-12-13 01:00:01.000000Z]
    end
  end

  @invalid_attrs %{
    identifier: nil,
    timezone: nil,
    lights_off: nil,
    lights_on: nil,
    watering_duration_secs: nil,
    watering_interval_days: nil,
    watering_time: nil
  }

  @valid_attrs %{
    identifier: "some identifier",
    # Chosen b/c always UTC+1
    timezone: "Africa/Lagos",
    lights_duration: ~T[14:00:00],
    lights_on: ~T[14:00:00],
    watering_duration_secs: 42,
    watering_interval_days: 42,
    watering_time: ~T[14:00:00],
    tank_base_area: 3.3,
    tank_max_depth: 12.0
  }

  test "list/0 returns all Impl" do
    plant = inserted_plant_fixture()
    assert Impl.list() == [plant]
  end

  test "get!/1 returns the plant with given id" do
    plant = inserted_plant_fixture()
    assert Impl.get!(plant.id) == plant
  end

  test "create/1 with valid data creates a plant" do
    assert {:ok, %Plant{} = plant} = Impl.create(@valid_attrs)
    assert plant.identifier == "some identifier"
    assert plant.timezone == "Africa/Lagos"
    assert plant.lights_duration == ~T[14:00:00]
    assert plant.lights_on == ~T[14:00:00]
    assert plant.watering_duration_secs == 42
    assert plant.watering_interval_days == 42
    assert plant.watering_time == ~T[14:00:00]
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Impl.create(@invalid_attrs)
  end

  test "create/1 with invalid timezone returns error changeset" do
    attrs = %{@valid_attrs | timezone: "Europe/Narnia"}
    assert {:error, _} = Impl.create(attrs)
  end

  test "update/2 with valid data updates the plant" do
    plant = inserted_plant_fixture()

    update_attrs = %{
      identifier: "some updated identifier",
      lights_on: ~T[15:01:01],
      lights_duration: ~T[15:01:01],
      watering_duration_secs: 43,
      watering_interval_days: 43,
      watering_time: ~T[15:01:01]
    }

    assert {:ok, %Plant{} = plant} = Impl.update(plant, update_attrs)
    assert plant.identifier == "some updated identifier"
    assert plant.lights_on == ~T[15:01:01]
    assert plant.lights_duration == ~T[15:01:01]
    assert plant.watering_duration_secs == 43
    assert plant.watering_interval_days == 43
    assert plant.watering_time == ~T[15:01:01]
  end

  test "update/2 with invalid data returns error changeset" do
    plant = inserted_plant_fixture()
    assert {:error, %Ecto.Changeset{}} = Impl.update(plant, @invalid_attrs)
    assert plant == Impl.get!(plant.id)
  end

  test "delete/1 deletes the plant" do
    plant = inserted_plant_fixture()
    assert {:ok, %Plant{}} = Impl.delete(plant)
    assert_raise Ecto.NoResultsError, fn -> Impl.get!(plant.id) end
  end

  test "returns a plant changeset" do
    plant = inserted_plant_fixture()
    assert %Ecto.Changeset{} = Impl.change(plant, %{})
  end

  def inserted_plant_fixture(attrs \\ %{}) do
    {:ok, plant} =
      attrs
      |> Enum.into(%{
        identifier: unique_plant_identifier(),
        # Chosen b/c UTC+1 year round
        timezone: "Africa/Lagos",
        lights_on: ~T[14:00:00],
        lights_duration: ~T[23:59:59],
        watering_duration_secs: 42,
        watering_interval_days: 42,
        watering_time: ~T[14:00:00],
        tank_base_area: 1,
        tank_max_depth: 10
      })
      |> Impl.create()

    plant
  end

  def inserted_watering_record_fixture(plant, attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      plant_id: plant.id,
      duration_secs: 42,
      scheduled?: true,
      at: ~U[2021-12-16 12:00:00.000000Z]
    })
    |> WateringRecord.changeset()
    |> Repo.insert!()
  end

  def inserted_lighting_record_fixture(plant, attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      plant_id: plant.id,
      scheduled?: true,
      on?: true,
      at: ~U[2021-12-16 12:00:00.000000Z]
    })
    |> LightingRecord.changeset()
    |> Repo.insert!()
  end

  def inserted_tank_level_record_fixture(plant, attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      plant_id: plant.id,
      failed?: false,
      remaining: 10.0,
      total: 20.0,
      at: ~U[2021-12-16 12:00:00.000000Z]
    })
    |> TankLevelRecord.changeset()
    |> Repo.insert!()
  end
end
