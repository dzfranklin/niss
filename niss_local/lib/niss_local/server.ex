defmodule NissLocal.Server do
  use GenServer
  require Logger

  defmodule State do
    defstruct lights_status: :unknown

    @type t :: %__MODULE__{
            lights_status: :unknown | :off | :on
          }
  end

  def start_link(opts \\ []) do
    state = %State{}
    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:lights, status}, _from, state) do
    ensure_valid_lights_status!(status)
    Logger.error("TODO")
    {:reply, :ok, %State{state | lights_status: status}}
  end

  def handle_call(:lights, _from, state) do
    Logger.error("TODO")
    {:reply, state.lights_status, state}
  end

  defp ensure_valid_lights_status!(status) do
    unless status in [:unknown, :off, :on] do
      raise "Invalid lights status #{inspect(status)}"
    end

    nil
  end
end
