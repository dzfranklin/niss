defmodule Niss.Auth do
  def valid?(pass) do
    Plug.Crypto.secure_compare(pass, correct_pass())
  end

  defp correct_pass do
    Application.get_env(:niss, __MODULE__)
    |> Keyword.fetch!(:pass)
  end
end
