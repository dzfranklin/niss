defmodule NissCore.RecordIR do
  require NissCore

  NissCore._setup_dispatch(__MODULE__.Real, __MODULE__.Mock)

  @type duration_nanos :: integer()
  @type state :: 1 | 0

  @spec start :: pid()
  def start do
    dispatch(:start, [])
  end

  @spec stop(pid()) :: [{duration_nanos(), state()}]
  def stop(pid) do
    dispatch(:stop, [pid])
  end
end
