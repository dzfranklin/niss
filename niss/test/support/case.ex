defmodule Niss.Case do
  use ExUnit.CaseTemplate

  using(opts) do
    maybe_setup_mock(opts)
  end

  def maybe_setup_mock(opts) do
    if Keyword.get(opts, :mock, false) do
      quote do
        import Mox
        setup :verify_on_exit!
        setup :set_mox_from_context
      end
    else
      quote do
      end
    end
  end
end
