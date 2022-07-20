defmodule Niss.PossessionsTest do
  use Niss.DataCase

  alias Niss.Possessions

  describe "possessions" do
    alias Niss.Possessions.Possession

    import Niss.PossessionsFixtures

    @invalid_attrs %{count: nil, description: nil, name: nil}

    test "list_possessions/0 returns all possessions" do
      possession = possession_fixture()
      assert Possessions.list_possessions() == [possession]
    end

    test "get_possession!/1 returns the possession with given id" do
      possession = possession_fixture()
      assert Possessions.get_possession!(possession.id) == possession
    end

    test "create_possession/1 with valid data creates a possession" do
      valid_attrs = %{count: 42, description: "some description", name: "some name"}

      assert {:ok, %Possession{} = possession} = Possessions.create_possession(valid_attrs)
      assert possession.count == 42
      assert possession.description == "some description"
      assert possession.name == "some name"
    end

    test "create_possession/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Possessions.create_possession(@invalid_attrs)
    end

    test "update_possession/2 with valid data updates the possession" do
      possession = possession_fixture()
      update_attrs = %{count: 43, description: "some updated description", name: "some updated name"}

      assert {:ok, %Possession{} = possession} = Possessions.update_possession(possession, update_attrs)
      assert possession.count == 43
      assert possession.description == "some updated description"
      assert possession.name == "some updated name"
    end

    test "update_possession/2 with invalid data returns error changeset" do
      possession = possession_fixture()
      assert {:error, %Ecto.Changeset{}} = Possessions.update_possession(possession, @invalid_attrs)
      assert possession == Possessions.get_possession!(possession.id)
    end

    test "delete_possession/1 deletes the possession" do
      possession = possession_fixture()
      assert {:ok, %Possession{}} = Possessions.delete_possession(possession)
      assert_raise Ecto.NoResultsError, fn -> Possessions.get_possession!(possession.id) end
    end

    test "change_possession/1 returns a possession changeset" do
      possession = possession_fixture()
      assert %Ecto.Changeset{} = Possessions.change_possession(possession)
    end
  end
end
