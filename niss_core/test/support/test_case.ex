defmodule NissCore.TestCase do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case, async: true
    end
  end
end
