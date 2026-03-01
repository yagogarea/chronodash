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

defmodule Chronodash.Metrics.Observation do
  @moduledoc """
  Unified table for all time-series metrics.
  Designed to be a TimescaleDB hypertable with composite PK for upserts.
  """
  use Ash.Resource,
    otp_app: :chronodash,
    domain: Chronodash.Metrics,
    data_layer: AshPostgres.DataLayer

  attributes do
    attribute :location_id, :uuid do
      primary_key?(true)
      allow_nil?(false)
      public?(true)
    end

    attribute :metric_type, :string do
      primary_key?(true)
      allow_nil?(false)
      description("e.g., temperature, wind_speed, sky_state")
      public?(true)
    end

    attribute :timestamp, :utc_datetime_usec do
      primary_key?(true)
      allow_nil?(false)
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
      source_attribute(:location_id)
      allow_nil?(false)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:location_id, :metric_type, :value, :unit, :timestamp, :source, :metadata])
      upsert?(true)
      upsert_identity(:unique_observation)
      upsert_fields([:value, :unit, :source, :metadata])
    end
  end

  identities do
    identity(:unique_observation, [:location_id, :metric_type, :timestamp])
  end

  postgres do
    table "observations"
    repo Chronodash.Repo

    references do
      reference :location, on_delete: :delete
    end
  end
end
