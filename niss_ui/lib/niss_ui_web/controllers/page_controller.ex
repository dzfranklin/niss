defmodule NissUiWeb.PageController do
  use NissUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
