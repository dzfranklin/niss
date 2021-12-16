defmodule Niss.Query do
  import Ecto.Query
  alias Niss.Repo

  defmacro __using__(_) do
    quote do
      import Ecto.Query, warn: false
      import Niss.Query, warn: false
    end
  end

  def get_first(query, by_field \\ :created_at) do
    query
    |> order_by(asc: ^by_field)
    |> limit(1)
    |> Repo.one()
  end

  def get_last(query, by_field \\ :created_at) do
    query
    |> order_by(desc: ^by_field)
    |> limit(1)
    |> Repo.one()
  end
end
