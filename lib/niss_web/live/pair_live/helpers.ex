defmodule NissWeb.PairLive.Helpers do
  alias Niss.PubSub

  def request_pic(prim), do:
    broadcast!(prim, :request_pic)

  def subscribe(prim) do
      PubSub.subscribe("pair:" <> prim)
  end

  def unsubscribe(prim) do
      PubSub.unsubscribe("pair:" <> prim)
  end

  def broadcast!(prim, msg) do
    PubSub.broadcast!("pair:" <> prim, {:pair, msg})
  end
end
