defmodule NissCore.RecordIRTest do
  use NissCore.TestCase
  alias NissCore.RecordIR, as: Subject

  test "start/0 & stop/1" do
    recorder = Subject.start()
    recording = Subject.stop(recorder)
    assert [{_duration, _value} | _] = recording
  end
end
