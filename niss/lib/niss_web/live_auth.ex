defmodule NissWeb.LiveAuth do
  import Phoenix.LiveView

  def mount(_params, %{"authed?" => true} = _session, socket) do
    {:cont, socket}
  end

  def mount(_params, _session, socket) do
    {:halt, redirect(socket, to: "/auth")}
  end
end
