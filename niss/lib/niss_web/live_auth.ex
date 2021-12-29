defmodule NissWeb.LiveAuth do
  import Phoenix.LiveView

  def on_mount(:default, _params, %{"authed?" => true} = _session, socket) do
    {:cont, assign(socket, :authed?, true)}
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, redirect(socket, to: "/auth")}
  end

  def on_mount(:optional, _params, session, socket) do
    authed? = Map.get(session, "authed?", false)
    {:cont, assign(socket, :authed?, authed?)}
  end
end
