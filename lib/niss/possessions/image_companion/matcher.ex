defmodule Niss.Possessions.ImageCompanion.Matcher do
  use GenServer

  @type relationship_id :: String.t()
  @type server :: GenServer.server()

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, nil, opts)

  # Api

  @spec register_primary(server()) :: {:ok, relationship_id()}
  def register_primary(server \\ __MODULE__), do: GenServer.call(server, :register_primary)

  @spec register_companion(server(), relationship_id()) ::
          {:ok, pid()} | {:error, :not_found}
  def register_companion(server \\ __MODULE__, relationship_id),
    do: GenServer.call(server, {:register_companion, relationship_id})

  # Implementation

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:register_primary, {prim, _}, state) do
    id = generate_id()
    {:reply, {:ok, id}, Map.put(state, id, prim: prim)}
  end

  @impl true
  def handle_call({:register_companion, relship_id}, {comp, _}, state) do
    relship = Map.get(state, relship_id)

    if is_nil(relship) do
      {:reply, {:error, :not_found}, state}
    else
      prim = Keyword.fetch!(relship, :prim)
      send(prim, {:found_image_companion, comp})
      {:reply, {:ok, prim}, Map.delete(state, relship_id)}
    end
  end

  defp generate_id, do: Ecto.UUID.generate()
end
