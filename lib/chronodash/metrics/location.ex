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
      description("ID used by external providers (e.g. MeteoSIX locationId)")
      public?(true)
    end

    timestamps()
  end

  actions do
    defaults([
      :read,
      :destroy,
      create: [:name, :latitude, :longitude, :external_id],
      update: [:name, :latitude, :longitude, :external_id]
    ])
  end

  postgres do
    table "locations"
    repo Chronodash.Repo
  end

  relationships do
    has_many :observations, Chronodash.Metrics.Observation
  end
end
