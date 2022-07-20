defmodule Niss.Possessions do
  @moduledoc """
  The Possessions context.
  """

  import Ecto.Query, warn: false
  alias Niss.Repo

  alias Niss.Possessions.Possession

  @doc """
  Returns the list of possessions.

  ## Examples

      iex> list_possessions()
      [%Possession{}, ...]

  """
  def list_possessions do
    Repo.all(Possession)
  end

  @doc """
  Gets a single possession.

  Raises `Ecto.NoResultsError` if the Possession does not exist.

  ## Examples

      iex> get_possession!(123)
      %Possession{}

      iex> get_possession!(456)
      ** (Ecto.NoResultsError)

  """
  def get_possession!(id), do: Repo.get!(Possession, id)

  @doc """
  Creates a possession.

  ## Examples

      iex> create_possession(%{field: value})
      {:ok, %Possession{}}

      iex> create_possession(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_possession(attrs \\ %{}) do
    %Possession{}
    |> Possession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a possession.

  ## Examples

      iex> update_possession(possession, %{field: new_value})
      {:ok, %Possession{}}

      iex> update_possession(possession, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_possession(%Possession{} = possession, attrs) do
    possession
    |> Possession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a possession.

  ## Examples

      iex> delete_possession(possession)
      {:ok, %Possession{}}

      iex> delete_possession(possession)
      {:error, %Ecto.Changeset{}}

  """
  def delete_possession(%Possession{} = possession) do
    Repo.delete(possession)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking possession changes.

  ## Examples

      iex> change_possession(possession)
      %Ecto.Changeset{data: %Possession{}}

  """
  def change_possession(%Possession{} = possession, attrs \\ %{}) do
    Possession.changeset(possession, attrs)
  end
end
