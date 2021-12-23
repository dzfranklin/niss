defmodule Niss.ExecutorImplTest do
  use Niss.Case, async: false, mock: true
  alias Timex.Duration
  alias Niss.Now
  alias Niss.Executor.Impl
  import Niss.PlantsFixtures

  @timeout 100

  setup do
    stub(Niss.Now.MockImpl, :utc_now, fn -> ~U[2021-12-16 14:42:42.000000Z] end)
    :ok
  end

  test "scheduled/1" do
    plant = plant_fixture()
    watering = watering_record_fixture(plant)
    lighting = lighting_record_fixture(plant)

    Niss.Plants.MockImpl
    |> expect(:list, fn -> [plant] end)
    |> expect(:scheduled_watering, fn ^plant -> watering end)
    |> expect(:scheduled_lighting, fn ^plant -> lighting end)

    {:ok, serv} = Impl.start_link()

    assert %{
             ^plant => %{
               lighting: ^lighting,
               watering: ^watering
             }
           } = Impl.scheduled(serv, @timeout)
  end

  describe "load/1" do
    test "loads fresh" do
      plant_1 = plant_fixture()
      watering_1 = watering_record_fixture(plant_1)
      lighting_1 = lighting_record_fixture(plant_1)

      plant_2 = plant_fixture()
      watering_2 = watering_record_fixture(plant_2)
      lighting_2 = lighting_record_fixture(plant_2)

      Niss.Plants.MockImpl
      # First load
      |> expect(:list, fn -> [plant_1] end)
      |> expect(:scheduled_watering, fn ^plant_1 -> watering_1 end)
      |> expect(:scheduled_lighting, fn ^plant_1 -> lighting_1 end)
      # After reload
      |> expect(:list, fn -> [plant_2] end)
      |> expect(:scheduled_watering, fn ^plant_2 -> watering_2 end)
      |> expect(:scheduled_lighting, fn ^plant_2 -> lighting_2 end)

      {:ok, serv} = Impl.start_link()

      assert %{
               ^plant_1 => %{
                 lighting: ^lighting_1,
                 watering: ^watering_1
               }
             } = Impl.scheduled(serv, @timeout)

      Impl.load(serv, @timeout)

      assert %{
               ^plant_2 => %{
                 lighting: ^lighting_2,
                 watering: ^watering_2
               }
             } = Impl.scheduled(serv, @timeout)
    end

    test "cancels existing"
  end

  describe "load_plant/2" do
    test "loads fresh" do
      plant = plant_fixture(%{watering_duration_secs: 1})

      # Even if we change a prop it's still the same plant
      updated_plant = Map.put(plant, :watering_duration_secs, 2)

      watering = watering_record_fixture(plant)
      lighting_1 = lighting_record_fixture(plant)
      lighting_2 = lighting_record_fixture(plant)

      Niss.Plants.MockImpl
      # First load
      |> expect(:list, fn -> [plant] end)
      |> expect(:scheduled_watering, fn ^plant -> watering end)
      |> expect(:scheduled_lighting, fn ^plant -> lighting_1 end)
      # After reload
      |> expect(:scheduled_watering, fn ^updated_plant -> watering end)
      |> expect(:scheduled_lighting, fn ^updated_plant -> lighting_2 end)

      {:ok, serv} = Impl.start_link()

      scheduled = Impl.scheduled(serv, @timeout)
      assert map_size(scheduled) == 1

      assert scheduled[plant] == %{
               watering: watering,
               lighting: lighting_1
             }

      Impl.load_plant(serv, updated_plant, @timeout)

      scheduled = Impl.scheduled(serv, @timeout)
      assert map_size(scheduled) == 1

      assert scheduled[updated_plant] == %{
               watering: watering,
               lighting: lighting_2
             }
    end

    test "cancels existing"
  end

  test "maybe_cancel_plant"

  describe "executes" do
    @near_future_millis 100
    @receive_future_timeout 150
    @receive_immediate_timeout 20

    setup do
      now = Now.utc_now()

      {:ok,
       %{
         at_near_future: Timex.add(now, Duration.from_milliseconds(@near_future_millis)),
         at_far_future: Timex.add(now, Duration.from_weeks(12)),
         at_past: Timex.subtract(now, Duration.from_seconds(1))
       }}
    end

    test "lighting on in future", %{at_near_future: at_near_future, at_far_future: at_far_future} do
      tester = self()
      plant = plant_fixture()
      watering = watering_record_fixture(plant, %{at: at_far_future})
      lighting = lighting_record_fixture(plant, %{at: at_near_future})

      Niss.Plants.MockImpl
      |> expect(:list, fn -> [plant] end)
      |> expect(:scheduled_watering, fn ^plant -> watering end)
      |> expect(:scheduled_lighting, fn ^plant -> lighting end)
      |> expect(:execute!, fn record -> send(tester, {:executing, record}) end)

      {:ok, _serv} = Impl.start_link()

      assert_receive {:executing, ^lighting}, @receive_future_timeout
    end

    test "lighting for past immediately", %{at_past: at_past, at_far_future: at_far_future} do
      tester = self()
      plant = plant_fixture()
      watering = watering_record_fixture(plant, %{at: at_far_future})
      lighting = lighting_record_fixture(plant, %{at: at_past})

      Niss.Plants.MockImpl
      |> expect(:list, fn -> [plant] end)
      |> expect(:scheduled_watering, fn ^plant -> watering end)
      |> expect(:scheduled_lighting, fn ^plant -> lighting end)
      |> expect(:execute!, fn record -> send(tester, {:executing, record}) end)

      {:ok, _serv} = Impl.start_link()

      assert_receive {:executing, ^lighting}, @receive_immediate_timeout
    end

    test "watering in future", %{at_far_future: at_far_future, at_near_future: at_near_future} do
      tester = self()
      plant = plant_fixture()
      lighting = lighting_record_fixture(plant, %{at: at_far_future})
      watering = watering_record_fixture(plant, %{at: at_near_future})

      Niss.Plants.MockImpl
      |> expect(:list, fn -> [plant] end)
      |> expect(:scheduled_watering, fn ^plant -> watering end)
      |> expect(:scheduled_lighting, fn ^plant -> lighting end)
      |> expect(:execute!, fn record -> send(tester, {:executing, record}) end)

      {:ok, _serv} = Impl.start_link()

      assert_receive {:executing, ^watering}, @receive_future_timeout
    end

    test "watering for past immediately", %{at_far_future: at_far_future, at_past: at_past} do
      tester = self()
      plant = plant_fixture()
      lighting = lighting_record_fixture(plant, %{at: at_far_future})
      watering = watering_record_fixture(plant, %{at: at_past})

      Niss.Plants.MockImpl
      |> expect(:list, fn -> [plant] end)
      |> expect(:scheduled_watering, fn ^plant -> watering end)
      |> expect(:scheduled_lighting, fn ^plant -> lighting end)
      |> expect(:execute!, fn record -> send(tester, {:executing, record}) end)

      {:ok, _serv} = Impl.start_link()

      assert_receive {:executing, ^watering}, @receive_immediate_timeout
    end
  end
end
