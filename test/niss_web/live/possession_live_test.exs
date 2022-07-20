defmodule NissWeb.PossessionLiveTest do
  use NissWeb.ConnCase

  import Phoenix.LiveViewTest
  import Niss.PossessionsFixtures

  @create_attrs %{count: 42, description: "some description", name: "some name"}
  @update_attrs %{count: 43, description: "some updated description", name: "some updated name"}
  @invalid_attrs %{count: nil, description: nil, name: nil}

  defp create_possession(_) do
    possession = possession_fixture()
    %{possession: possession}
  end

  describe "Index" do
    setup [:create_possession]

    test "lists all possessions", %{conn: conn, possession: possession} do
      {:ok, _index_live, html} = live(conn, Routes.possession_index_path(conn, :index))

      assert html =~ "Listing Possessions"
      assert html =~ possession.description
    end

    test "saves new possession", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.possession_index_path(conn, :index))

      assert index_live |> element("a", "New Possession") |> render_click() =~
               "New Possession"

      assert_patch(index_live, Routes.possession_index_path(conn, :new))

      assert index_live
             |> form("#possession-form", possession: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#possession-form", possession: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.possession_index_path(conn, :index))

      assert html =~ "Possession created successfully"
      assert html =~ "some description"
    end

    test "updates possession in listing", %{conn: conn, possession: possession} do
      {:ok, index_live, _html} = live(conn, Routes.possession_index_path(conn, :index))

      assert index_live |> element("#possession-#{possession.id} a", "Edit") |> render_click() =~
               "Edit Possession"

      assert_patch(index_live, Routes.possession_index_path(conn, :edit, possession))

      assert index_live
             |> form("#possession-form", possession: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#possession-form", possession: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.possession_index_path(conn, :index))

      assert html =~ "Possession updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes possession in listing", %{conn: conn, possession: possession} do
      {:ok, index_live, _html} = live(conn, Routes.possession_index_path(conn, :index))

      assert index_live |> element("#possession-#{possession.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#possession-#{possession.id}")
    end
  end

  describe "Show" do
    setup [:create_possession]

    test "displays possession", %{conn: conn, possession: possession} do
      {:ok, _show_live, html} = live(conn, Routes.possession_show_path(conn, :show, possession))

      assert html =~ "Show Possession"
      assert html =~ possession.description
    end

    test "updates possession within modal", %{conn: conn, possession: possession} do
      {:ok, show_live, _html} = live(conn, Routes.possession_show_path(conn, :show, possession))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Possession"

      assert_patch(show_live, Routes.possession_show_path(conn, :edit, possession))

      assert show_live
             |> form("#possession-form", possession: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#possession-form", possession: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.possession_show_path(conn, :show, possession))

      assert html =~ "Possession updated successfully"
      assert html =~ "some updated description"
    end
  end
end
