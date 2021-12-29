defmodule NissWeb.PlantRecordComponent do
  @moduledoc """
  A plant record is a LightingRecord or WateringRecord
  """
  use NissWeb, :component
  alias Niss.Plants
  alias Plants.{LightingRecord, WateringRecord}
  alias NissWeb.TimeComponent

  @doc """
  Params:
    - `record`: A plant record, with plant preloaded
    - `intl`: `NissWeb.PutIntlLive.Intl`
  """
  def oneline(assigns) do
    ~H"""
    <span>
      <%= if scheduled?(@record) do %>
        <Heroicons.Outline.calendar class={icon_cls()} alt="Scheduled"/>
      <% end %>

      <TimeComponent.time_with_alternate class="text-gray-600"
        time={@record.at} primary_tz={@intl.tz} alternate_tz={@record.plant.timezone}
      />

      <%= plant_name(@record) %>

      <span>
        <%= case @record do %>
        <% %LightingRecord{on?: true} -> %>
          <Heroicons.Solid.sun class={icon_cls()} alt="Light on"/>
        <% %LightingRecord{on?: false} -> %>
          <Heroicons.Outline.sun class={icon_cls()} alt="Light off"/>
        <% %WateringRecord{duration_secs: secs} -> %>
          <Heroicons.Outline.beaker class={icon_cls()} alt="Watered"/>
          <span class="text-gray-700"><%= secs %>s</span>
        <% end %>
      </span>
    </span>
    """
  end

  defp icon_cls, do: "inline-block w-5 h-5 text-gray-500"

  defp scheduled?(record), do: Map.get(record, :scheduled?, false)

  defp plant_name(record), do: Plants.pretty_name(record.plant)
end
