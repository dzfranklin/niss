defmodule NissCore.CeilingStrip.SignalsTest do
  use NissCore.TestCase
  alias NissCore.CeilingStrip.Signals

  test "signal!/1" do
    actual = Signals.signal!(:on)
    expected = <<0, 255, 224, 31>>
    assert actual == expected
  end
end
