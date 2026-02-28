defmodule Chronodash.Models.DataSource.MeteoSIX.WRF.ForecastTest do
  use ExUnit.Case, async: true
  alias Chronodash.Metrics.ObservationData
  alias Chronodash.Models.DataSource.MeteoSIX.WRF.Forecast

  describe "to_observation_data/2" do
    test "correctly parses and normalizes simple metric (temperature)" do
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

      observations = Forecast.to_observation_data(response, :temperature)
      assert is_list(observations)
      [obs] = observations

      assert %ObservationData{} = obs
      assert obs.location_name == "Test City"
      assert obs.latitude == 43.37
      assert obs.metric_type == "temperature"
      assert obs.value == 15.5
      assert obs.unit == "degC"
      assert obs.timestamp == ~U[2026-02-28 09:00:00Z]
    end

    test "correctly parses and splits composite metric (wind)" do
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

      observations = Forecast.to_observation_data(response, :wind)
      assert length(observations) == 2

      module = Enum.find(observations, &(&1.metric_type == "wind_module"))
      direction = Enum.find(observations, &(&1.metric_type == "wind_direction"))

      assert module.value == 20.0
      assert module.unit == "kmh"
      assert direction.value == 180.0
      assert direction.unit == "deg"
    end

    test "normalizes sky state strings to numeric values" do
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

      [obs] = Forecast.to_observation_data(response, :sky_state)
      assert obs.value == 2.0
    end
  end
end
