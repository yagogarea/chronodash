# Elixir backend that analyzes meteoFIX data, provides insights, and integrates with Grafana.

# Copyright (C) 2026 Santiago Garea Cidre, Paula Carril Gontán, and Saúl Zas Carballal

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).

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
