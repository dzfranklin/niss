defmodule NissWeb.PlantLiveTest do
  use NissWeb.ConnCase, async: true, mock: true
  import Phoenix.LiveViewTest
  alias Ecto.Changeset
  import Niss.PlantsFixtures
  alias Niss.Plants

  @create_attrs %{
    identifier: "some identifier",
    timezone: "America/Denver",
    lights_on: %{hour: 14, minute: 0},
    lights_duration: %{hour: 10, minute: 30},
    watering_interval_days: 42,
    watering_time: %{hour: 14, minute: 0},
    watering_duration_secs: 42,
    tank_base_area: 2.1,
    tank_max_depth: 12.5
  }

  @update_attrs %{
    identifier: "some updated identifier",
    timezone: "Europe/London",
    lights_on: %{hour: 15, minute: 1},
    lights_duration: %{hour: 6, minute: 0},
    watering_interval_days: 43,
    watering_time: %{hour: 15, minute: 1},
    watering_duration_secs: 43,
    tank_base_area: 2,
    tank_max_depth: 12
  }

  @invalid_attrs %{
    identifier: nil,
    timezone: "Europe/Narnia",
    lights_on: %{hour: 14, minute: 0},
    lights_duration: %{hour: 6, minute: 0},
    watering_interval_days: nil,
    watering_time: %{hour: 14, minute: 0},
    watering_duration_secs: nil,
    tank_base_area: nil,
    tank_max_depth: nil
  }

  setup do
    utc_now = ~U[2021-12-16 14:42:42.000000Z]

    stub(Niss.Now.MockImpl, :utc_now, fn -> utc_now end)

    stub(Niss.Now.MockImpl, :now_in!, fn tz ->
      case Timex.Timezone.convert(utc_now, tz) do
        {:error, error} -> raise "mock now_in!/1 #{inspect(error)}"
        datetime -> datetime
      end
    end)

    stub(Plants.MockImpl, :change, &Plants.Plant.changeset/2)
    :ok
  end

  defp create(_) do
    plant = plant_fixture()

    stub(Plants.MockImpl, :list, fn -> [plant] end)

    stub(Plants.MockImpl, :get!, fn id ->
      if id == plant.id do
        plant
      else
        raise "Plant with id #{inspect(id)} not found"
      end
    end)

    %{plant: plant}
  end

  describe "Index" do
    @describetag :authed?
    setup [:create]

    test "lists all plants", %{conn: conn, plant: plant} do
      {:ok, _index_live, html} = live(conn, Routes.plant_index_path(conn, :index))

      assert html =~ "Listing Plants"
      assert html =~ plant.identifier
    end

    test "saves new plant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.plant_index_path(conn, :index))

      assert index_live |> element("a", "New Plant") |> render_click() =~
               "New Plant"

      assert_patch(index_live, Routes.plant_index_path(conn, :new))

      assert index_live
             |> form("#plant-form", plant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      expect(Plants.MockImpl, :create, fn attrs ->
        Plants.Plant.changeset(attrs)
        |> Changeset.apply_action(:insert)
      end)

      {:ok, _, html} =
        index_live
        |> form("#plant-form", plant: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.plant_index_path(conn, :index))

      assert html =~ "Plant created successfully"
    end

    test "updates plant in listing", %{conn: conn, plant: plant} do
      {:ok, index_live, _html} = live(conn, Routes.plant_index_path(conn, :index))

      assert index_live |> element("#plant-#{plant.id} a", "Edit") |> render_click() =~
               "Edit Plant"

      assert_patch(index_live, Routes.plant_index_path(conn, :edit, plant))

      assert index_live
             |> form("#plant-form", plant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      expect(Plants.MockImpl, :update, fn plant, attrs ->
        Plants.Plant.changeset(plant, attrs)
        |> Changeset.apply_action(:update)
      end)

      {:ok, _, html} =
        index_live
        |> form("#plant-form", plant: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.plant_index_path(conn, :index))

      assert html =~ "Plant updated successfully"
    end

    test "deletes plant in listing", %{conn: conn, plant: plant} do
      {:ok, index_live, _html} = live(conn, Routes.plant_index_path(conn, :index))
      expect(Plants.MockImpl, :delete, fn plant -> {:ok, plant} end)
      assert index_live |> element("#plant-#{plant.id} a", "Delete") |> render_click()
    end
  end

  describe "Show" do
    @describetag :authed?
    setup [:create]

    test "displays plant", %{conn: conn, plant: plant} do
      {:ok, _show_live, html} = live(conn, Routes.plant_show_path(conn, :show, plant))

      assert html =~ "Show Plant"
      assert html =~ plant.identifier
    end

    test "updates plant within modal", %{conn: conn, plant: plant} do
      {:ok, show_live, _html} = live(conn, Routes.plant_show_path(conn, :show, plant))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Plant"

      assert_patch(show_live, Routes.plant_show_path(conn, :edit, plant))

      assert show_live
             |> form("#plant-form", plant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      expect(Plants.MockImpl, :update, fn plant, attrs ->
        Plants.Plant.changeset(plant, attrs)
        |> Changeset.apply_action(:update)
      end)

      {:ok, _, html} =
        show_live
        |> form("#plant-form", plant: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.plant_show_path(conn, :show, plant))

      assert html =~ "Plant updated successfully"
    end
  end
end
