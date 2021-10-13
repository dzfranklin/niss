defmodule NissCore.RecordIR do
  require NissCore

  NissCore._setup_dispatch(__MODULE__.Real, __MODULE__.Mock)

  @type recorder :: pid()
  @type duration_nanos :: integer()
  @type state :: 1 | 0
  @type recording :: [{duration_nanos(), state()}]

  @spec start :: recorder()
  def start do
    dispatch(:start, [])
  end

  @spec stop(recorder()) :: recording()
  def stop(pid) do
    dispatch(:stop, [pid])
  end
end
