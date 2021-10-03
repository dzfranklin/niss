defmodule NissTest do
  use ExUnit.Case
  doctest Niss

  test "greets the world" do
    assert Niss.hello() == :world
  end
end
