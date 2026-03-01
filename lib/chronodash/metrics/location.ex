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
