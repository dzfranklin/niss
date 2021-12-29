defmodule NissWeb.PutIntl do
  import Phoenix.LiveView

  defmodule Intl do
    defstruct [:locale, :tz]
  end

  def on_mount(:default, _params, _session, socket) do
    intl =
      if connected?(socket) do
        params =
          socket
          |> get_connect_params()
          |> Map.get("intl", %{})

        %Intl{
          locale: Map.fetch!(params, "locale"),
          tz: Map.fetch!(params, "timezone")
        }
      else
        %Intl{
          locale: "en-US",
          tz: "America/New_York"
        }
      end

    {:cont, assign(socket, :intl, intl)}
  end
end
