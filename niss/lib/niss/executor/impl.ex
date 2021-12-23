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
  def scheduled(serv \\ __MODULE__, timeout),
    do: GenServer.call(serv, :scheduled, timeout)

  @impl true
  def load(serv \\ __MODULE__, timeout), do: GenServer.call(serv, :load, timeout)

  @impl true
  def load_plant(serv \\ __MODULE__, %Plant{} = plant, timeout),
    do: GenServer.call(serv, {:load_plant, plant}, timeout)

  @impl true
  def maybe_cancel_plant(serv \\ __MODULE__, %Plant{} = plant, timeout),
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
    {:reply, nil, _maybe_cancel_plant(state, plant)}
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
    _cancel_all(state.plants, state.scheduled)

    plants = Plants.list()
    %{state | plants: Map.new(plants, &{&1.id, &1}), scheduled: _schedule_all(plants)}
  end

  defp _load_plant(state, plant) do
    _maybe_cancel_plant(plant, state.scheduled)

    state
    |> Map.update!(:plants, fn val -> Map.put(val, plant.id, plant) end)
    |> Map.update!(:scheduled, fn val -> _schedule_plant(plant, val) end)
  end

  defp _cancel_all(plants, scheduled) do
    for {_id, plant} <- plants do
      _maybe_cancel_plant(plant, scheduled)
    end

    nil
  end

  defp _schedule_all(plants) do
    Enum.reduce(plants, %{}, &_schedule_plant/2)
  end

  defp _schedule_plant(plant, scheduled) do
    _maybe_cancel_plant(plant, scheduled)

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

  defp _maybe_cancel_plant(plant, scheduled) do
    records = Map.get(scheduled, plant.id)

    unless is_nil(records) do
      if Map.has_key?(records, :watering) do
        {_record, old_timer} = records.watering
        Process.cancel_timer(old_timer)
      end

      if Map.has_key?(records, :lighting) do
        {_record, old_timer} = records.lighting
        Process.cancel_timer(old_timer)
      end
    end
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
