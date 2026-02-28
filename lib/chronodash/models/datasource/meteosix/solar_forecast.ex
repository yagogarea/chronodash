defmodule Chronodash.Models.DataSource.MeteoSIX.SolarForecast do
  @moduledoc """
  DTO for MeteoSIX solar info data (`/getSolarInfo`).
  """

  defstruct [:coords, days: []]

  @type solar_day :: %{
          date: Date.t() | nil,
          sunrise: DateTime.t() | nil,
          midday: DateTime.t() | nil,
          sunset: DateTime.t() | nil,
          duration: String.t() | nil
        }

  @type t :: %__MODULE__{
          coords: {float(), float()} | nil,
          days: list(solar_day())
        }

  @doc """
  Parses a MeteoSIX `/getSolarInfo` response into a SolarForecast DTO.
  """
  def new(response) do
    case response["features"] do
      [feature | _] ->
        {:ok,
         %__MODULE__{
           coords: extract_coords(feature["geometry"]),
           days: parse_days(feature["properties"]["days"])
         }}

      _ ->
        {:error, :no_data}
    end
  end

  defp extract_coords(%{"coordinates" => [lon, lat]}), do: {lat, lon}
  defp extract_coords(_), do: nil

  defp parse_days(nil), do: []

  defp parse_days(days) do
    Enum.map(days, fn day ->
      var = Enum.find(day["variables"], fn v -> v["name"] == "solar" end)

      %{
        date: parse_date(get_in(day, ["timePeriod", "begin", "timeInstant"])),
        sunrise: parse_timestamp(var["sunrise"]),
        midday: parse_timestamp(var["midday"]),
        sunset: parse_timestamp(var["sunset"]),
        duration: var["duration"]
      }
    end)
  end

  defp parse_date(nil), do: nil
  defp parse_date(ts), do: ts |> parse_timestamp() |> DateTime.to_date()

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(ts) do
    normalised = Regex.replace(~r/([+-]\d{2})$/, ts, "\\1:00")

    case DateTime.from_iso8601(normalised) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
