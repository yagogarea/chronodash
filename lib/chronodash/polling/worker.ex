defmodule Chronodash.Polling.Worker do
  @moduledoc """
  A generic worker that polls a datasource and saves results.
  """
  use GenServer
  require Logger
  require Ash.Query

  @doc """
  Starts a polling worker.
  """
  def start_link(opts) do
    id = Map.fetch!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: via_tuple(id))
  end

  defp via_tuple(id), do: {:via, Registry, {Chronodash.Registry, {:polling_worker, id}}}

  @impl true
  def init(opts) do
    state = %{
      id: Map.fetch!(opts, :id),
      mfa: Map.fetch!(opts, :mfa),
      rate: Map.fetch!(opts, :rate),
      metadata: Map.get(opts, :metadata, %{})
    }

    send(self(), :poll)
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    {mod, fun, args} = state.mfa

    case apply(mod, fun, args) do
      {:ok, forecast} ->
        handle_success(forecast, state)

      {:error, reason} ->
        Logger.error("Polling job #{state.id} failed: #{inspect(reason)}")
        emit_telemetry(state, :error, %{reason: inspect(reason)})
    end

    schedule_next(state.rate)
    {:noreply, state}
  end

  defp handle_success(forecast, state) do
    # 1. Find or create the location in our DB
    location = get_or_create_location(forecast)

    # 2. Save all forecast points to the DB
    # TODO: If you eventually poll thousands of locations, you could batch the Ash.bulk_create calls
    # (e.g., save in groups of 500 using Enum.chunk_every/2) to avoid long-running transactions.
    if Map.has_key?(forecast, :points) do
      Enum.each(forecast.points, fn point ->
        Enum.each(point.metrics, fn metric ->
          save_observation(metric, point.timestamp, location, state)
          emit_observation(metric, point.timestamp, forecast.location_name, state)
        end)
      end)
    end

    emit_telemetry(state, :success, %{})
  end

  defp get_or_create_location(forecast) do
    if is_nil(forecast.location_name) or forecast.location_name == "" do
      Logger.error("Cannot get/create location: location_name is missing in forecast DTO.")
      nil
    else
      # 1. Use name + coordinates to ensure uniqueness
      {lat, lon} = forecast.coords || {0.0, 0.0}

      params = %{
        name: forecast.location_name,
        latitude: lat,
        longitude: lon
      }

      # 2. Use create action with upsert? true
      case Chronodash.Metrics.Location
           |> Ash.Changeset.for_create(:create, params)
           |> Ash.create(domain: Chronodash.Metrics) do
        {:ok, loc} ->
          loc

        {:error, error} ->
          Logger.error(
            "Failed to get/create location '#{forecast.location_name}': #{inspect(error)}"
          )

          nil
      end
    end
  end

  defp save_observation(metric, timestamp, location, state) do
    if is_nil(location) do
      Logger.error("Cannot save observation for #{metric.name} because location is nil.")
    else
      source = Map.get(state.metadata, :source, "unknown")

      params = %{
        location_id: location.id,
        metric_type: metric.name,
        value: normalize_value(metric.value),
        unit: metric.unit,
        timestamp: timestamp,
        source: source,
        metadata: %{original_value: metric.value}
      }

      case Chronodash.Metrics.Observation
           |> Ash.Changeset.for_create(:create, params)
           |> Ash.create(domain: Chronodash.Metrics) do
        {:ok, _obs} ->
          :ok

        {:error, error} ->
          Logger.error("Failed to upsert observation #{metric.name}: #{inspect(error)}")
      end
    end
  end

  defp emit_observation(metric, timestamp, location_name, state) do
    # We emit a metric for each data point
    measurements = %{value: normalize_value(metric.value)}

    metadata =
      Map.merge(state.metadata, %{
        location: location_name,
        variable: metric.name,
        timestamp: timestamp
      })

    :telemetry.execute([:chronodash, :polling, :observation], measurements, metadata)
  end

  defp emit_telemetry(state, status, extra_metadata) do
    metadata = Map.merge(state.metadata, extra_metadata) |> Map.put(:status, status)
    :telemetry.execute([:chronodash, :polling, :run], %{count: 1}, metadata)
  end

  defp normalize_value(v) when is_number(v), do: v * 1.0

  defp normalize_value(v) when is_binary(v) do
    cond do
      # Handle numeric strings
      Regex.match?(~r/^-?\d+(\.\d+)?$/, v) ->
        {f, _} = Float.parse(v)
        f

      # Sky States
      v == "SUNNY" ->
        1.0

      v == "PARTLY_CLOUDY" ->
        2.0

      v == "HIGH_CLOUDS" ->
        3.0

      v == "CLOUDY" ->
        4.0

      v == "OVERCAST" ->
        5.0

      true ->
        0.0
    end
  end

  defp normalize_value(_), do: 0.0

  defp schedule_next(rate) do
    Process.send_after(self(), :poll, rate)
  end
end
