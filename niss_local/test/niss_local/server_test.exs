defmodule NissLocalTest.ServerTest do
  use ExUnit.Case, async: true
  alias NissLocal.Server, as: Subject

  test "can start" do
    assert {:ok, pid} = Subject.start_link()
    assert is_pid(pid)
  end
end
