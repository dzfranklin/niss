defmodule NissUi.Auth.Login do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @correct_password Application.fetch_env!(:niss_ui, :correct_password)

  embedded_schema do
    field :password, :string
  end

  def changeset(login \\ %__MODULE__{}, attrs) do
    login
    |> cast(attrs, [:password])
    |> check_password()
  end

  defp check_password(change) do
    password = fetch_field!(change, :password)

    case password do
      @correct_password -> change
      nil -> add_error(change, :password, "can't be blank")
      _ -> add_error(change, :password, "is incorrect")
    end
  end

  @spec check(Changeset.t()) :: :ok | {:error, Changeset.t()}
  def check(change) do
    apply_action(change, :check)
    |> case do
      {:ok, _} -> :ok
      {:error, change} -> change
    end
  end
end
