defmodule Chronodash.Metrics.Observation do
  @moduledoc """
  Unified table for all time-series metrics.
  Designed to be a TimescaleDB hypertable.
  """
  use Ash.Resource,
    otp_app: :chronodash,
    domain: Chronodash.Metrics,
    data_layer: AshPostgres.DataLayer

  attributes do
    # TimescaleDB hypertables with unique indexes (including PK) 
    # MUST include the partitioning column (timestamp).
    uuid_primary_key :id do
      default(&Ash.UUID.generate/0)
      public?(true)
    end

    attribute :timestamp, :utc_datetime_usec do
      primary_key?(true)
      allow_nil?(false)
      public?(true)
    end

    attribute :metric_type, :string do
      allow_nil?(false)
      description("e.g., temperature, wind_speed, sky_state")
      public?(true)
    end

    attribute :value, :float do
      allow_nil?(false)
      public?(true)
    end

    attribute :unit, :string do
      public?(true)
    end

    attribute :source, :string do
      allow_nil?(false)
      description("e.g., meteosix, openweather")
      public?(true)
    end

    attribute :metadata, :map do
      default(%{})
      public?(true)
    end

    timestamps()
  end

  relationships do
    belongs_to :location, Chronodash.Metrics.Location do
      public?(true)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:metric_type, :value, :unit, :timestamp, :source, :metadata, :location_id])
    end
  end

  postgres do
    table "observations"
    repo Chronodash.Repo

    references do
      reference :location, on_delete: :delete
    end
  end
end
