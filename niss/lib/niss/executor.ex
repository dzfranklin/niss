defmodule Niss.Executor do
  use GenServer
  require Logger
  alias Niss.{Now, Plants}
  alias Plants.{Plant, LightingRecord, WateringRecord}

  @type serv :: GenServer.server()

  @timeout 5_000

  # Public api

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Get the plants loaded and scheduled.
  """
  @spec scheduled(serv(), timeout()) :: %{
          Plant.t() => %{lighting: LightingRecord.t(), watering: WateringRecord.t()}
        }
  def scheduled(serv \\ __MODULE__, timeout \\ @timeout),
    do: GenServer.call(serv, :scheduled, timeout)

  @doc """
  Load the list of plants and their scheduling info from the database and
  schedule them.
  """
  @spec load(serv(), timeout()) :: nil
  def load(serv \\ __MODULE__, timeout \\ @timeout), do: GenServer.call(serv, :load, timeout)

  @doc """
  Load the scheduling info for a plant from the database and schedule i.
  """
  @spec load_plant(serv(), Plant.t(), timeout()) :: nil
  def load_plant(serv \\ __MODULE__, %Plant{} = plant, timeout \\ @timeout),
    do: GenServer.call(serv, {:load_plant, plant}, timeout)

  # Internal

  @impl true
  def init(_) do
    {:ok, %{scheduled: %{}, plants: %{}}, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    {:noreply, _load(state)}
  end

  @impl true
  def handle_call(:load, _from, state) do
    {:reply, nil, _load(state)}
  end

  @impl true
  def handle_call({:load_plant, plant}, _from, state) do
    {:reply, nil, _load_plant(state, plant)}
  end

  @impl true
  def handle_call(:scheduled, _from, state) do
    scheduled =
      Map.new(
        state.scheduled,
        fn {plant_id,
            %{
              lighting: {lighting, _lighting_timer},
              watering: {watering, _watering_timer}
            }} ->
          {
            Map.fetch!(state.plants, plant_id),
            %{lighting: lighting, watering: watering}
          }
        end
      )

    {:reply, scheduled, state}
  end

  @impl true
  def handle_info({:execute, record}, state) do
    Logger.info("Received msg to execute: #{inspect(record, pretty: true)}")
    Plants.execute!(record)
    {:noreply, state}
  end

  defp _load(state) do
    # TODO: Cancel plants no longer in list
    plants = Plants.list()
    %{state | plants: Map.new(plants, &{&1.id, &1}), scheduled: _schedule_all(plants)}
  end

  defp _load_plant(state, plant) do
    state
    |> Map.update!(:plants, fn val -> Map.put(val, plant.id, plant) end)
    |> Map.update!(:scheduled, fn val -> _schedule_plant(plant, val) end)
  end

  defp _schedule_all(plants) do
    Enum.reduce(plants, %{}, &_schedule_plant/2)
  end

  defp _schedule_plant(plant, scheduled) do
    Map.put(scheduled, plant.id, %{})
    |> _schedule_watering(plant)
    |> _schedule_lighting(plant)
  end

  defp _schedule_watering(scheduled, plant) do
    prev = Map.get(scheduled, plant.id)

    if !is_nil(prev) && Map.has_key?(prev, :watering) do
      {_record, old_timer} = prev.watering
      Process.cancel_timer(old_timer)
    end

    record = Plants.scheduled_watering(plant)
    timer = _schedule_msg_at(record.at, {:execute, record})

    Logger.info(
      "scheduler: scheduled watering for #{plant.id}/#{plant.identifier} at #{record.at}"
    )

    Map.update(scheduled, plant.id, %{}, fn prev ->
      Map.put(prev, :watering, {record, timer})
    end)
  end

  defp _schedule_lighting(scheduled, plant) do
    prev = Map.get(scheduled, plant.id)

    if !is_nil(prev) && Map.has_key?(prev, :lighting) do
      {_record, old_timer} = prev.lighting
      Process.cancel_timer(old_timer)
    end

    record = Plants.scheduled_lighting(plant)
    timer = _schedule_msg_at(record.at, {:execute, record})

    Logger.info(
      "scheduler: scheduled lighting for #{plant.id}/#{plant.identifier} at #{record.at} to #{record.on?}"
    )

    Map.update(scheduled, plant.id, %{}, fn prev ->
      Map.put(prev, :lighting, {record, timer})
    end)
  end

  def _schedule_msg_at(at, msg) do
    millis = Timex.diff(at, Now.utc_now(), :millisecond)

    if millis < 0 do
      Logger.debug("scheduling immediately: #{inspect(msg, pretty: true)}")
      Process.send_after(self(), msg, 0)
    else
      Logger.debug("scheduling in #{millis}: #{inspect(msg, pretty: true)}")
      Process.send_after(self(), msg, millis)
    end
  end
end
