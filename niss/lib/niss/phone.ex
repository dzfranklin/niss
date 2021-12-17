defmodule Niss.Phone do
  @moduledoc """
  The Phone context.
  """
  import Ecto.Query, warn: false
  alias Phoenix.PubSub
  alias Niss.Repo
  alias Niss.Phone.Text
  alias Niss.PubSub

  @doc """
  Subscribe the current process to texts sent to `to_number`.

  You will receive messages of the form `{:new, %Text{}}`.
  """
  def subscribe_to_texts(to_number), do: PubSub.subscribe("phone_text:#{to_number}")

  @doc """
  Returns the list of texts.
  """
  def list_texts do
    Repo.all(Text)
  end

  @doc """
  Gets a single text.

  Raises `Ecto.NoResultsError` if the Text does not exist.
  """
  def get_text!(id), do: Repo.get!(Text, id)

  @doc """
  Creates a text.
  """
  def create_text(attrs \\ %{}) do
    Text.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, text} ->
        PubSub.broadcast("phone_text:#{text.to_number}", {:new, text})
        {:ok, text}

      {:error, change} ->
        {:error, change}
    end
  end

  @doc """
  Deletes a text.
  """
  def delete_text(%Text{} = text) do
    Repo.delete(text)
  end
end
