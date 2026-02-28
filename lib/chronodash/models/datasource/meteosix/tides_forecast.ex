defmodule Chronodash.Models.DataSource.MeteoSIX.TidesForecast do
  @moduledoc """
  DTO for MeteoSIX tidal info data (`/getTidesInfo`).
  """

  defstruct [:coords, days: []]

  @type tides_event :: %{
          id: String.t(),
          state: String.t(),
          timestamp: DateTime.t() | nil,
          height: float() | nil
        }

  @type tides_reading :: %{
          timestamp: DateTime.t() | nil,
          height: float() | nil
        }

  @type tides_day :: %{
          date: Date.t() | nil,
          units: String.t() | nil,
          summary: list(tides_event()),
          values: list(tides_reading())
        }

  @type t :: %__MODULE__{
          coords: {float(), float()} | nil,
          days: list(tides_day())
        }

  @doc """
  Parses a MeteoSIX `/getTidesInfo` response into a TidesForecast DTO.
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
      var = Enum.find(day["variables"], fn v -> v["name"] == "tides" end)

      %{
        date: parse_date(get_in(day, ["timePeriod", "begin", "timeInstant"])),
        units: var["units"],
        summary: parse_summary(var["summary"]),
        values: parse_values(var["values"])
      }
    end)
  end

  defp parse_summary(nil), do: []

  defp parse_summary(events) do
    Enum.map(events, fn e ->
      %{
        id: e["id"],
        state: e["state"],
        timestamp: parse_timestamp(e["timeInstant"]),
        height: e["height"]
      }
    end)
  end

  defp parse_values(nil), do: []

  defp parse_values(readings) do
    Enum.map(readings, fn r ->
      %{
        timestamp: parse_timestamp(r["timeInstant"]),
        height: r["height"]
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
