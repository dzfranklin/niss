defmodule NissWeb.PageController do
  use NissWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
