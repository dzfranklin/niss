defmodule NissLocal do
  @moduledoc """
  The portion of Niss that runs locally on the hub rpi.
  """

  def scripts_dir do
    priv = :code.priv_dir(:niss_local)
    Path.join([priv, "scripts"])
  end
end
