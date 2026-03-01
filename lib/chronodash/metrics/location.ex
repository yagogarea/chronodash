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

defmodule Chronodash.Metrics.Location do
  @moduledoc """
  Represents a physical location or station where metrics are collected.
  """
  use Ash.Resource,
    otp_app: :chronodash,
    domain: Chronodash.Metrics,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :latitude, :float do
      allow_nil?(false)
      public?(true)
    end

    attribute :longitude, :float do
      allow_nil?(false)
      public?(true)
    end

    attribute :external_id, :string do
      public?(true)
    end

    timestamps()
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:name, :latitude, :longitude, :external_id])
      upsert?(true)
      upsert_identity(:name)
      upsert_fields([:latitude, :longitude, :external_id])
    end
  end

  identities do
    identity(:name, [:name])
  end

  postgres do
    table "locations"
    repo Chronodash.Repo
  end

  relationships do
    has_many :observations, Chronodash.Metrics.Observation
  end
end
