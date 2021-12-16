defmodule Niss.TankLevelMonitorTest do
  use Niss.Case, async: true, mock: true
  alias Ecto.Changeset
  import ExUnit.CaptureLog
  alias Niss.{Local, Now, Plants, TankLevelMonitor}
  alias Plants.TankLevelRecord
  import Niss.PlantsFixtures

  test "handle_info(:do_scheduled, _)" do
    caller = self()
    {:ok, serv} = TankLevelMonitor.start_link()

    Now.MockImpl
    |> allow(self(), serv)
    |> stub(:utc_now, fn -> ~U[2021-12-16 14:42:42.000000Z] end)

    {:ok, next_id_agent} = Agent.start_link(fn -> 1 end)

    Plants.MockImpl
    |> allow(self(), serv)
    |> expect(:list, fn ->
      [
        plant_fixture(%{id: 1, identifier: "plant_1", tank_base_area: 0.005, tank_max_depth: 4}),
        plant_fixture(%{id: 2, identifier: "plant_2", tank_base_area: 0.010, tank_max_depth: 2})
      ]
    end)
    |> expect(:create_tank_level_record, 2, fn record ->
      id = Agent.get_and_update(next_id_agent, fn id -> {id, id + 1} end)

      record =
        TankLevelRecord.changeset(record)
        |> Changeset.apply_action!(:insert)
        |> Map.put(:id, id)

      send(caller, {:recorded, record})

      {:ok, record}
    end)

    Local.MockImpl
    |> allow(self(), serv)
    |> expect(:water_levels!, fn :plant_1 ->
      [{1, true}, {2, true}, {3, false}]
    end)
    |> expect(:water_levels!, fn :plant_2 ->
      [{0.5, true}, {1, true}, {1.5, true}, {2.0, true}]
    end)

    send(serv, :do_scheduled)

    assert_receive {:recorded, %TankLevelRecord{plant_id: 1, remaining: 10.0, total: 20.0}}

    assert_receive {:recorded, %TankLevelRecord{plant_id: 2, remaining: 20.0, total: 20.0}}
  end

  describe "calc_highest_level/1" do
    test "with partial" do
      levels = [{5, true}, {10, true}, {15, false}]
      assert TankLevelMonitor._calc_highest_level(levels) == {:ok, 10}
    end

    test "with full" do
      levels = [{5, true}, {10, true}, {15, true}]
      assert TankLevelMonitor._calc_highest_level(levels) == {:ok, 15}
    end

    test "with none" do
      levels = [{5, false}, {10, false}, {15, false}]
      assert TankLevelMonitor._calc_highest_level(levels) == {:ok, 0}
    end

    test "with inconsistent" do
      levels = [{5, true}, {10, false}, {15, true}]

      capture_log([level: :warn], fn ->
        assert TankLevelMonitor._calc_highest_level(levels) == {:error, :inconsistent}
      end) =~ "inconsistent reading"
    end
  end
end
