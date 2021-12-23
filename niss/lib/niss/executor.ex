defmodule Niss.Executor do
  alias Niss.Plants
  alias Plants.{Plant, LightingRecord, WateringRecord}

  @type serv :: GenServer.server()

  @timeout 5_000
  @adapter Application.fetch_env!(:niss, :adapters)[:executor]

  @callback start_link(keyword) :: GenServer.on_start()
  defdelegate start_link(opts \\ []), to: @adapter

  @doc """
  Get the plants loaded and scheduled.
  """
  @callback scheduled(serv(), timeout()) :: %{
              Plant.t() => %{lighting: LightingRecord.t(), watering: WateringRecord.t()}
            }
  defdelegate scheduled(serv \\ __MODULE__, timeout \\ @timeout), to: @adapter

  @doc """
  Loads and schedules a fresh list of plants from the database.

  Removes any plants not in the fresh load.
  """
  @callback load(serv(), timeout()) :: nil
  defdelegate load(serv \\ __MODULE__, timeout \\ @timeout), to: @adapter

  @doc """
  Schedule the plant. If it was already scheduled clears existing info.
  """
  @callback load_plant(serv(), Plant.t(), timeout()) :: nil
  defdelegate load_plant(serv \\ __MODULE__, plant, timeout \\ @timeout), to: @adapter

  @doc """
  Clears info for a plant, if it was scheduled.
  """
  @callback maybe_cancel_plant(serv(), Plant.t(), timeout()) :: nil
  defdelegate maybe_cancel_plant(serv \\ __MODULE__, plant, timeout \\ @timeout),
    to: @adapter
end
