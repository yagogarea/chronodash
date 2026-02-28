defmodule Chronodash.Alerting.Manager do
  @moduledoc """
  Subscribes to telemetry, evaluates alert rules, and manages alert cooldowns.
  """
  use GenServer
  require Logger
  alias Chronodash.Alerting.Dispatcher

  @table_name :alert_cooldowns

  # ============================================================================
  # PUBLIC API
  # ============================================================================

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Telemetry handler callback. Redirects to GenServer for state-aware evaluation.
  """
  def handle_telemetry_event(event, measurements, metadata, _config) do
    GenServer.cast(__MODULE__, {:evaluate, event, measurements, metadata})
  end

  # ============================================================================
  # GenServer Callbacks
  # ============================================================================

  @impl true
  def init(_opts) do
    :ets.new(@table_name, [:set, :protected, :named_table])

    :telemetry.attach_many(
      "chronodash-alert-manager",
      [
        [:chronodash, :polling, :observation],
        [:chronodash, :polling, :forecast_received]
      ],
      &__MODULE__.handle_telemetry_event/4,
      nil
    )

    {:ok, %{}}
  end

  @impl true
  def handle_cast(
        {:evaluate, [:chronodash, :polling, :observation], %{value: value}, metadata},
        state
      ) do
    get_instant_rules()
    |> Enum.each(&process_instant_rule(&1, value, metadata))

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:evaluate, [:chronodash, :polling, :forecast_received], _measurements, metadata},
        state
      ) do
    get_window_rules()
    |> Enum.each(&process_window_rule(&1, metadata))

    {:noreply, state}
  end

  # ============================================================================
  # Internal Functions - Processing
  # ============================================================================

  defp process_instant_rule(rule, value, metadata) do
    if not in_cooldown?(rule, metadata.location) and should_alert_point?(rule, value, metadata) do
      trigger_alert(rule, value, metadata)
    end
  end

  defp process_window_rule(rule, metadata) do
    if not in_cooldown?(rule, metadata.location) do
      {triggered, peak_value} = evaluate_forecast(rule, metadata.points)
      if triggered, do: trigger_alert(rule, peak_value, metadata)
    end
  end

  # ============================================================================
  # Internal Functions - Evaluation
  # ============================================================================

  defp evaluate_forecast(rule, points) do
    window_end = DateTime.add(DateTime.utc_now(), rule.window_hours, :hour)

    points
    |> filter_relevant_points(rule, window_end)
    |> check_forecast_condition(rule.condition, rule.threshold)
  end

  defp filter_relevant_points(points, rule, window_end) do
    for p <- points,
        DateTime.compare(p.timestamp, window_end) != :gt,
        m <- p.metrics,
        metric_name_match?(m.name, rule.metric),
        do: normalize_raw_value(m.value)
  end

  defp metric_name_match?(m_name, rule_metric) do
    to_string(m_name) == to_string(rule_metric) or
      (to_string(rule_metric) == "wind" and m_name == "wind_module")
  end

  defp check_forecast_condition([], _cond, _thresh), do: {false, nil}

  defp check_forecast_condition(values, :max_gt, thresh) do
    max = Enum.max(values)
    {max > thresh, max}
  end

  defp check_forecast_condition(values, :max_lt, thresh) do
    max = Enum.max(values)
    {max < thresh, max}
  end

  defp check_forecast_condition(values, :min_lt, thresh) do
    min = Enum.min(values)
    {min < thresh, min}
  end

  defp check_forecast_condition(values, :gt_any, thresh) do
    val = Enum.find(values, &(&1 > thresh))
    {!is_nil(val), val}
  end

  defp check_forecast_condition(_, _, _), do: {false, nil}

  # ============================================================================
  # Helper Functions
  # ============================================================================

  defp in_cooldown?(rule, location) do
    cooldown_ms = Map.get(rule, :cooldown_hours, 24) * 3600 * 1000
    now = System.system_time(:millisecond)

    case :ets.lookup(@table_name, {rule.id, location}) do
      [{{_id, _loc}, last_triggered_at}] -> now - last_triggered_at < cooldown_ms
      [] -> false
    end
  end

  defp should_alert_point?(rule, value, metadata) do
    metric_match = to_string(rule.metric) == to_string(metadata.variable)
    if metric_match, do: evaluate_condition(rule.condition, value, rule.threshold), else: false
  end

  defp trigger_alert(rule, value, metadata) do
    :ets.insert(@table_name, {{rule.id, metadata.location}, System.system_time(:millisecond)})
    message = format_message(rule.message, value, metadata)
    Dispatcher.dispatch(message, rule.channels)
    Logger.info("Alert triggered: #{rule.id} for #{metadata.location}. Entering cooldown.")
  end

  defp normalize_raw_value(v) when is_number(v), do: v * 1.0

  defp normalize_raw_value(v) when is_binary(v) do
    case Float.parse(v) do
      {f, _} -> f
      _ -> 0.0
    end
  end

  defp normalize_raw_value(_), do: 0.0

  defp evaluate_condition(:gt, val, thresh), do: val > thresh
  defp evaluate_condition(:lt, val, thresh), do: val < thresh
  defp evaluate_condition(:eq, val, thresh), do: val == thresh
  defp evaluate_condition(_, _, _), do: false

  defp format_message(template, value, metadata) do
    template
    |> String.replace("%{location}", to_string(metadata.location))
    |> String.replace("%{value}", to_string(value))
    |> String.replace("%{variable}", to_string(metadata.variable))
  end

  defp get_instant_rules do
    get_rules() |> Enum.reject(&Map.has_key?(&1, :window_hours))
  end

  defp get_window_rules do
    get_rules() |> Enum.filter(&Map.has_key?(&1, :window_hours))
  end

  defp get_rules do
    config = Application.get_env(:chronodash, :alerts, [])
    Keyword.get(config, :rules, [])
  end
end
