defmodule NissFwTest do
  use ExUnit.Case
  doctest NissFw

  test "greets the world" do
    assert NissFw.hello() == :world
  end
end
