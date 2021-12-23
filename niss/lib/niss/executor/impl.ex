defmodule Niss.Executor.Impl do
  @behaviour Niss.Executor
  use GenServer
  require Logger
  alias Niss.{Now, Plants}
  alias Plants.Plant

  # Public api

  @impl true
  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def scheduled(serv \\ {:global, __MODULE__}, timeout),
    do: GenServer.call(serv, :scheduled, timeout)

  @impl true
  def load(serv \\ {:global, __MODULE__}, timeout), do: GenServer.call(serv, :load, timeout)

  @impl true
  def load_plant(serv \\ {:global, __MODULE__}, %Plant{} = plant, timeout),
    do: GenServer.call(serv, {:load_plant, plant}, timeout)

  @impl true
  def maybe_cancel_plant(serv \\ {:global, __MODULE__}, %Plant{} = plant, timeout),
    do: GenServer.call(serv, {:maybe_cancel_plant, plant}, timeout)

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
  def handle_call({:maybe_cancel_plant, plant}, _from, state) do
    {:reply, nil, _maybe_unload_plant(state, plant)}
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
    plants = Plants.list()

    state
    |> _unload_all()
    |> Map.put(:plants, Map.new(plants, &{&1.id, &1}))
    |> Map.put(:scheduled, _schedule_all(plants))
  end

  defp _load_plant(state, plant) do
    state
    |> _maybe_unload_plant(plant)
    |> Map.update!(:plants, fn val -> Map.put(val, plant.id, plant) end)
    |> Map.update!(:scheduled, fn val -> _schedule_plant(plant, val) end)
  end

  defp _unload_all(state) do
    Enum.reduce(state.plants, state, fn {_id, plant}, state ->
      _maybe_unload_plant(state, plant)
    end)
  end

  defp _schedule_all(plants) do
    Enum.reduce(plants, %{}, &_schedule_plant/2)
  end

  defp _schedule_plant(plant, scheduled) do
    watering_record = Plants.scheduled_watering(plant)
    watering_timer = _schedule_msg_at(watering_record.at, {:execute, watering_record})

    lighting_record = Plants.scheduled_lighting(plant)
    lighting_timer = _schedule_msg_at(lighting_record.at, {:execute, lighting_record})

    Logger.info("executor: scheduled #{plant.id}/#{plant.identifier}")

    Map.put(scheduled, plant.id, %{
      watering: {watering_record, watering_timer},
      lighting: {lighting_record, lighting_timer}
    })
  end

  defp _maybe_unload_plant(state, plant) do
    state
    |> Map.update!(:scheduled, &_maybe_unschedule(plant, &1))
    |> Map.update!(:plants, &Map.delete(&1, plant.id))
  end

  defp _maybe_unschedule(plant, scheduled) do
    {records, scheduled} = Map.pop(scheduled, plant.id)

    unless is_nil(records) do
      Logger.info(
        "_maybe_unschedule: unscheduling #{plant.id}/#{plant.identifier}, was #{inspect(records, pretty: true)}"
      )

      if Map.has_key?(records, :watering) do
        {_record, old_timer} = records.watering
        Process.cancel_timer(old_timer)
      end

      if Map.has_key?(records, :lighting) do
        {_record, old_timer} = records.lighting
        Process.cancel_timer(old_timer)
      end
    end

    scheduled
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
