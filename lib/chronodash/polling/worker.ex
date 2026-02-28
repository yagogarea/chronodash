defmodule Chronodash.Polling.Worker do
  @moduledoc """
  A generic worker that polls a datasource and saves results in bulk.
  Decoupled from specific datasource logic via standardize ObservationData.
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
      {:ok, observations} when is_list(observations) ->
        handle_observations(observations, state)

      {:error, reason} ->
        Logger.error("Polling job #{state.id} failed: #{inspect(reason)}")
        emit_run_telemetry(state, :error)
    end

    schedule_next(state.rate)
    {:noreply, state}
  end

  defp handle_observations([], state) do
    Logger.debug("Polling job #{state.id} returned no data.")
    emit_run_telemetry(state, :success)
  end

  defp handle_observations(observations, state) do
    # 1. Ensure location exists (all observations in a poll usually share a location)
    first = List.first(observations)

    case get_or_create_location(first) do
      {:ok, location} ->
        # 2. Enrich observations with location_id and convert to maps for bulk create
        inputs =
          Enum.map(observations, fn obs ->
            emit_observation_telemetry(obs, state)

            %{
              location_id: location.id,
              metric_type: obs.metric_type,
              value: obs.value,
              unit: obs.unit,
              timestamp: obs.timestamp,
              source: obs.source,
              metadata: obs.metadata
            }
          end)

        # 3. Bulk Upsert
        # TODO: If you eventually poll thousands of locations, you could batch the Ash.bulk_create calls
        # (e.g., save in groups of 500 using Enum.chunk_every/2) to avoid long-running transactions.
        case Ash.bulk_create(inputs, Chronodash.Metrics.Observation, :create,
               domain: Chronodash.Metrics
             ) do
          %Ash.BulkResult{status: :success} ->
            Logger.info(
              "Polling job #{state.id}: successfully saved #{length(inputs)} observations."
            )

            emit_run_telemetry(state, :success)

          %Ash.BulkResult{errors: errors} ->
            Logger.error(
              "Polling job #{state.id}: failed to bulk save observations: #{inspect(errors)}"
            )

            emit_run_telemetry(state, :error)
        end

      {:error, error} ->
        Logger.error("Polling job #{state.id}: could not resolve location: #{inspect(error)}")
        emit_run_telemetry(state, :error)
    end
  end

  defp get_or_create_location(obs) do
    params = %{
      name: obs.location_name,
      latitude: obs.latitude,
      longitude: obs.longitude
    }

    case Chronodash.Metrics.Location
         |> Ash.Changeset.for_create(:create, params)
         |> Ash.create(domain: Chronodash.Metrics) do
      {:ok, loc} -> {:ok, loc}
      {:error, error} -> {:error, error}
    end
  end

  defp emit_observation_telemetry(obs, state) do
    measurements = %{value: obs.value}

    metadata =
      Map.merge(state.metadata, %{
        location: obs.location_name,
        variable: obs.metric_type,
        timestamp: obs.timestamp
      })

    :telemetry.execute([:chronodash, :polling, :observation], measurements, metadata)
  end

  defp emit_run_telemetry(state, status) do
    metadata = Map.merge(state.metadata, %{status: status, job_id: state.id})
    :telemetry.execute([:chronodash, :polling, :run], %{count: 1}, metadata)
  end

  defp schedule_next(rate) do
    Process.send_after(self(), :poll, rate)
  end
end
