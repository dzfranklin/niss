defmodule NissCore do
  @moduledoc """
  Documentation for `NissCore`.
  """

  @doc """
  Returns if `potential` is within +- `tolerance` percent of expected
  """
  def within_tolerance?(potential, expected, tolerance) do
    potential > expected * (1.0 - tolerance) && potential < expected * (1.0 + tolerance)
  end

  @doc """
  Returns if `potential` is above `expected` plus `tolerance` percent of `expected1
  """
  def above_tolerance?(potential, expected, tolerance) do
    potential > expected * (1.0 + tolerance)
  end

  @doc false
  defmacro _setup_dispatch(real_mod, mock_mod) do
    quote do
      defp dispatch(fun, args) do
        if Application.get_env(:niss_core, :mock?, false) do
          apply(unquote(mock_mod), fun, args)
        else
          apply(unquote(real_mod), fun, args)
        end
      end
    end
  end
end
