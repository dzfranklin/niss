defmodule Niss.Plants do
  alias __MODULE__.{WateringRecord, LightingRecord, TankLevelRecord}

  @adapter Application.fetch_env!(:niss, :adapters)[:plants]

  @callback pretty_name(Plant.t()) :: String.t()
  defdelegate pretty_name(plant), to: @adapter

  @doc """
  Get the (cached) water volume of the plant's tank. Units are liters.
  """
  @callback tank_level(Plant.t()) :: TankLevelRecord.t() | nil
  defdelegate tank_level(plant), to: @adapter

  @doc """
  Get the capacity of the tank in litres
  """
  @callback tank_capacity(Plant.t()) :: float()
  defdelegate tank_capacity(plant), to: @adapter

  @callback create_tank_level_record(map()) ::
              {:ok, TankLevelRecord.t()} | {:error, Changeset.t()}
  defdelegate create_tank_level_record(attrs), to: @adapter

  @doc """
  Execute a watering or lighting record. The `at` field is overridden with the
  time of execution, and a warning is raised if it is more than a minute from
  the current time.
  """
  @callback execute!(WateringRecord.t() | LightingRecord.t()) :: nil
  defdelegate execute!(record), to: @adapter

  @callback scheduled_lighting(Plant.t()) :: LightingRecord.t()
  defdelegate scheduled_lighting(plant), to: @adapter

  @callback scheduled_watering(Plant.t()) :: WateringRecord.t()
  defdelegate scheduled_watering(plant), to: @adapter

  @doc """
  List the final tank level of each day
  """
  @callback list_ending_tank_levels(DateTime.t(), DateTime.t()) :: [TankLevelRecord.t()]
  defdelegate list_ending_tank_levels(from, to), to: @adapter

  @doc """
  List lighting, watering records.

  `plant` is preloaded.
  """
  @callback list_records(DateTime.t(), DateTime.t()) :: [LightingRecord.t() | WateringRecord.t()]
  defdelegate list_records(from, to), to: @adapter

  @callback list :: [Plant.t()]
  defdelegate list, to: @adapter

  @callback get!(Plant.id()) :: Plant.t()
  defdelegate get!(id), to: @adapter

  @callback create(map()) :: {:ok, Plant.t()} | {:error, Changeset.t()}
  defdelegate create(attrs), to: @adapter

  @callback update(Plant.t(), map()) :: {:ok, Plant.t()} | {:error, Changeset.t()}
  defdelegate update(plant, attrs), to: @adapter

  @callback delete(map()) :: {:ok, Plant.t()} | {:error, Changeset.t()}
  defdelegate delete(plant), to: @adapter

  @callback change(Plant.t(), map()) :: Changeset.t()
  defdelegate change(plant, attrs \\ %{}), to: @adapter

  @callback identifier(Plant.t()) :: atom()
  defdelegate identifier(plant), to: @adapter
end
