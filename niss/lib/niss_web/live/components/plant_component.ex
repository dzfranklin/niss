defmodule NissWeb.PlantComponent do
  use NissWeb, :component
  alias Niss.Plants
  alias NissWeb.TimeComponent

  @doc """
  Params:
    - `plant`: `Plant`
    - `intl`: `PutIntlLive.Intl`
  """
  def summary(assigns) do
    ~H"""
    <div>
      <p>
        <%= Plants.pretty_name(@plant) %>
        (last updated <TimeComponent.datetime datetime={@plant.updated_at} tz={@intl.tz}/>)
      </p>

      <p>
        Lights on at
        <TimeComponent.time_with_alternate time={@plant.lights_on} store_tz={@plant.timezone}
          primary_tz={@intl.tz} alternate_tz={@plant.timezone}
        />
        for <TimeComponent.duration duration={@plant.lights_duration}/>.
      </p>

      <p>
        Water every <%= @plant.watering_interval_days %> days at
        <TimeComponent.time_with_alternate time={@plant.watering_time} store_tz={@plant.timezone}
          primary_tz={@intl.tz} alternate_tz={@plant.timezone}
        />
        for <%= @plant.watering_duration_secs %>.
      </p>

      <p>
      Tank capacity <%= Plants.tank_capacity(@plant) %> litres.
      </p>

      <p>
      Local timezone <%= @plant.timezone %>
      </p>
    </div>
    """
  end
end
