defmodule NissUi.Auth do
  alias __MODULE__.Token
  alias NissUi.Repo
  import Ecto.Query
  require Logger

  @spec allow?(:inet.ip_address(), binary() | nil) :: boolean()
  def allow?(ip, token) do
    ip = if is_binary(ip), do: ip, else: serialize_ip(ip)

    if is_nil(token) do
      false
    else
      case get_token(token) do
        {:ok, token} ->
          Logger.info("Authed #{ip} with token #{token.id}")
          true

        {:error, :nonexistent} ->
          Logger.info("Refused auth due to nonexistent token")
          false
      end
    end
  end

  @spec allow_live?(binary() | nil) :: boolean()
  def allow_live?(token) do
    if is_nil(token) do
      false
    else
      case get_token(token) do
        {:ok, token} ->
          Logger.info("Authed with token #{token.id}")
          true

        {:error, :nonexistent} ->
          Logger.info("Refused auth due to nonexistent token")
          false
      end
    end
  end

  @spec mint_token(:inet.ip_address()) :: binary()
  def mint_token(ip) do
    Token.changeset(%{
      token: Token.generate_token(),
      created_by_ip: serialize_ip(ip)
    })
    |> Repo.insert!()
    |> Map.get(:token)
  end

  @spec get_token(binary()) :: {:ok, Token.t()} | {:error, :nonexistent}
  defp get_token(token) do
    if is_nil(token) do
      raise "get_token/1: Missing token"
    end

    Token
    |> where(token: ^token)
    |> Repo.one()
    |> case do
      nil -> {:error, :nonexistent}
      %Token{} = token -> {:ok, token}
    end
  end

  def serialize_ip(ip) do
    case :inet.ntoa(ip) do
      {:error, error} -> raise "serialize_ip/1: #{inspect(error)}"
      ip -> to_string(ip)
    end
  end
end
