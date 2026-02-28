defmodule Chronodash.PromEx.MeteoSIXPlugin do
  @moduledoc """
  PromEx plugin for MeteoSIX metrics collected via the generic polling engine.
  """
  use PromEx.Plugin

  @impl true
  def event_metrics(_opts) do
    [
      meteosix_wrf_metrics()
    ]
  end

  defp meteosix_wrf_metrics do
    Event.build(
      :chronodash_meteosix_wrf_event,
      [
        last_value(
          [:chronodash, :meteosix, :wrf, :observation, :value],
          event_name: [:chronodash, :polling, :observation],
          description: "MeteoSIX WRF Forecast observation value.",
          measurement: :value,
          tags: [:variable, :location, :source]
        )
      ]
    )
  end
end
