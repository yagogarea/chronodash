defmodule Chronodash.Metrics.ObservationData do
  @moduledoc """
  A standardized internal struct representing a single metric observation.
  """
  defstruct [
    :location_name,
    :latitude,
    :longitude,
    :metric_type,
    :value,
    :unit,
    :timestamp,
    :source,
    :metadata
  ]

  @type t :: %__MODULE__{
          location_name: String.t(),
          latitude: float() | nil,
          longitude: float() | nil,
          metric_type: String.t(),
          value: float(),
          unit: String.t() | nil,
          timestamp: DateTime.t(),
          source: String.t(),
          metadata: map()
        }
end
