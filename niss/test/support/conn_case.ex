defmodule NissWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.
  """

  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import NissWeb.ConnCase

      alias NissWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint NissWeb.Endpoint

      unquote(Niss.Case.maybe_setup_mock(opts))
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
