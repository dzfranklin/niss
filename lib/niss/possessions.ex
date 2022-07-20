defmodule Niss.Possessions do
  @moduledoc """
  The Possessions context.
  """

  import Ecto.Query, warn: false
  alias Niss.Repo

  alias Niss.Possessions.Possession

  def list_possessions do
    Repo.all(Possession)
  end

  def get_possession!(id), do: Repo.get!(Possession, id)

  def create_possession(attrs \\ %{}) do
    %Possession{}
    |> Possession.changeset(attrs)
    |> Repo.insert()
  end

  def update_possession(%Possession{} = possession, attrs) do
    possession
    |> Possession.changeset(attrs)
    |> Repo.update()
  end

  def delete_possession(%Possession{} = possession) do
    Repo.delete(possession)
  end

  def change_possession(%Possession{} = possession, attrs \\ %{}) do
    Possession.changeset(possession, attrs)
  end
end
