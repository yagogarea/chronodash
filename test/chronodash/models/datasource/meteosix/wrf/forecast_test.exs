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
