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

defmodule Chronodash.Models.DataSource.MeteoSIX.WRF.ForecastTest do
  use ExUnit.Case, async: true
  alias Chronodash.Models.DataSource.MeteoSIX.WRF.Forecast

  describe "new/2" do
    test "correctly parses simple metric (temperature)" do
      response = %{
        "features" => [
          %{
            "geometry" => %{"coordinates" => [-8.42, 43.37], "type" => "Point"},
            "properties" => %{
              "name" => "Test City",
              "days" => [
                %{
                  "variables" => [
                    %{
                      "name" => "temperature",
                      "units" => "degC",
                      "values" => [
                        %{"timeInstant" => "2026-02-28T10:00:00+01", "value" => "15.5"}
                      ]
                    }
                  ]
                }
              ]
            }
          }
        ]
      }

      assert %Forecast{} = forecast = Forecast.new(response, :temperature)
      assert forecast.location_name == "Test City"
      assert forecast.coords == {43.37, -8.42}
      assert forecast.metric_type == :temperature

      [point] = forecast.points
      assert point.timestamp == ~U[2026-02-28 09:00:00Z]
      [metric] = point.metrics
      assert metric.name == "temperature"
      assert metric.value == "15.5"
      assert metric.unit == "degC"
    end

    test "correctly parses composite metric (wind)" do
      response = %{
        "features" => [
          %{
            "geometry" => %{"coordinates" => [-8.42, 43.37], "type" => "Point"},
            "properties" => %{
              "name" => "Port Area",
              "days" => [
                %{
                  "variables" => [
                    %{
                      "name" => "wind",
                      "moduleUnits" => "kmh",
                      "directionUnits" => "deg",
                      "values" => [
                        %{
                          "timeInstant" => "2026-02-28T12:00:00+01",
                          "moduleValue" => 20.0,
                          "directionValue" => 180.0
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          }
        ]
      }

      assert %Forecast{} = forecast = Forecast.new(response, :wind)
      assert forecast.metric_type == :wind

      [point] = forecast.points
      assert length(point.metrics) == 2

      module = Enum.find(point.metrics, &(&1.name == "wind_module"))
      direction = Enum.find(point.metrics, &(&1.name == "wind_direction"))

      assert module.value == 20.0
      assert module.unit == "kmh"
      assert direction.value == 180.0
      assert direction.unit == "deg"
    end

    test "returns raw sky state strings" do
      response = %{
        "features" => [
          %{
            "geometry" => %{"coordinates" => [-8.42, 43.37], "type" => "Point"},
            "properties" => %{
              "days" => [
                %{
                  "variables" => [
                    %{
                      "name" => "sky_state",
                      "values" => [
                        %{"timeInstant" => "2026-02-28T10:00:00+01", "value" => "PARTLY_CLOUDY"}
                      ]
                    }
                  ]
                }
              ]
            }
          }
        ]
      }

      forecast = Forecast.new(response, :sky_state)
      [point] = forecast.points
      [metric] = point.metrics
      assert metric.value == "PARTLY_CLOUDY"
    end
  end
end
