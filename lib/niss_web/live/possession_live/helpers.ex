defmodule NissWeb.PossessionLive.Helpers do
  import Phoenix.LiveView.Helpers
  alias Niss.Possessions.Possession

  def maybe_possession_img(%Possession{image_id: id}, variant)
      when not is_nil(id) do
    assigns = %{src: "/possession_images/v1_#{id}_#{variant}.jpeg"}

    ~H"""
    <img src={@src}>
    """
  end

  def maybe_possession_img(_, _), do: nil
end
