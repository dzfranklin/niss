defmodule NissCore do
  @moduledoc """
  Documentation for `NissCore`.
  """

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
