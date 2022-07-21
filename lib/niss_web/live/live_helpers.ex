defmodule NissWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  alias Phoenix.LiveView
  alias Niss.Accounts

  @doc """
  Renders a liveview inside the `NissWeb.ModalComponent` component.

  Required opts:
  - `return_to`: URL to return to when modal is closed. Provided to liveview via
    session

  Optional opts:
  - `session`: Session to pass to liveview
  """
  def live_modal(lv, opts) do
    path = Keyword.fetch!(opts, :return_to)

    session = Keyword.get(IO.inspect(opts), :session, %{})
      |> Map.put("return_to", path)

    modal_opts = [id: :modal, lv_id: :modal_lv, return_to: path, lv: lv, session: session]
    live_component(NissWeb.ModalComponent, IO.inspect(modal_opts))
  end

  def ensure_authed(socket, session) do
    socket = assign_current_user(socket, session)

    if is_nil(socket.assigns.current_user) do
      raise "Missing auth"
    else
      socket
    end
  end

  def assign_current_user(socket, session) do
    LiveView.assign_new(
      socket,
      :current_user,
      fn -> Accounts.get_user_by_session_token(session["user_token"]) end
    )
  end
end
