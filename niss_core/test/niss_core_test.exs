defmodule NissCoreTest do
  use ExUnit.Case
  doctest NissCore

  test "greets the world" do
    assert NissCore.hello() == :world
  end
end
