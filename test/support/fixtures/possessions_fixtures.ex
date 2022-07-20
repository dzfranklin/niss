defmodule Niss.PossessionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Niss.Possessions` context.
  """

  @doc """
  Generate a possession.
  """
  def possession_fixture(attrs \\ %{}) do
    {:ok, possession} =
      attrs
      |> Enum.into(%{
        count: 42,
        description: "some description",
        name: "some name"
      })
      |> Niss.Possessions.create_possession()

    possession
  end
end
