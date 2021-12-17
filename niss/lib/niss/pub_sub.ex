defmodule Niss.PubSub do
  alias Phoenix.PubSub

  def subscribe(topic, opts \\ []) do
    PubSub.subscribe(__MODULE__, topic, opts)
  end

  def broadcast(topic, message) do
    PubSub.broadcast(__MODULE__, topic, message)
  end

  def broadcast!(topic, message) do
    PubSub.broadcast!(__MODULE__, topic, message)
  end
end
