defmodule Niss.Phone do
  @moduledoc """
  The Phone context.
  """
  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Phoenix.PubSub
  require Logger
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
    change = Text.changeset(attrs)

    case Changeset.apply_action(change, :insert) do
      {:ok, text} ->
        # The changeset appears valid, first optimistically broadcast and then check with the db
        PubSub.broadcast("phone_text:#{text.to_number}", {:new, text})

        case Repo.insert(change) do
          {:ok, text} ->
            {:ok, text}

          {:error, change} ->
            # At some point we might want to broadcast a deletion
            Logger.error(
              "Optimistically broadcast invalid text\n#{inspect(change, pretty: true)}"
            )

            {:error, change}
        end

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
