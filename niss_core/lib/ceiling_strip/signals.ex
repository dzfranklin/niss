defmodule NissCore.CeilingStrip.Signals do
  @name_to_signal %{
    function_next: <<0, 255, 160, 95>>,
    function_prev: <<0, 255, 32, 223>>,
    off: <<0, 255, 96, 159>>,
    on: <<0, 255, 224, 31>>,
    speed_faster: <<0, 255, 144, 111>>,
    speed_slower: <<0, 255, 16, 239>>,
    more_color_options: <<0, 255, 80, 175>>,
    color_on_off: <<0, 255, 208, 47>>,
    color_red: <<0, 255, 176, 79>>,
    color_green: <<0, 255, 48, 207>>,
    color_blue: <<0, 255, 112, 143>>,
    color_brighter: <<0, 255, 240, 15>>,
    color_yellow: <<0, 255, 168, 87>>,
    color_cyan: <<0, 255, 40, 215>>,
    color_violet: <<0, 255, 104, 151>>,
    color_dimmer: <<0, 255, 232, 23>>,
    white_cool: <<0, 255, 152, 103>>,
    white_warm: <<0, 255, 24, 231>>,
    white_both: <<0, 255, 136, 119>>,
    white_tune_cooler: <<0, 255, 88, 167>>,
    white_tune_warmer: <<0, 255, 72, 183>>,
    white_on_off: <<0, 255, 8, 247>>,
    white_brighter: <<0, 255, 216, 39>>,
    white_dimmer: <<0, 255, 200, 55>>
  }

  @moduledoc """
  Definitions for supported signals.

  ## Notes

  I don't fully understand function cycles and `:more_color_options`.

  Function cycles (`:function_next` and `:function_prev`) include jump, fade, and normal.

  `:white_cool` is 6500K and `:white_warm` is 2200K.

  There are six levels of brightness for white and color (`:{white,color}_{brighter,dimmer}`).

  Between fully `:white_cool`/`:white_warm` and even there are two intermediate states each.

  ## Names:

  #{Map.keys(@name_to_signal) |> Enum.map(&inspect/1) |> Enum.join(", ")}
  """

  @type name :: atom()
  @type signal :: <<_::32>>

  @spec signal!(name()) :: signal()
  @doc """
  Get a signal by name, raising on nonexistent.

  See module-level documentation for list of names.
  """
  def signal!(name), do: Map.fetch!(@name_to_signal, name)
end
