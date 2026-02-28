defmodule Chronodash.Accounts.User do
  @moduledoc """
  User resource for Chronodash. Represents a user of the application with their preferences.
  """
  use Ash.Resource,
    otp_app: :chronodash,
    domain: Chronodash.Accounts,
    data_layer: AshPostgres.DataLayer

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :email,
             :city,
             :alert_hours,
             :inserted_at,
             :updated_at
           ]}

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :email, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :city, :string do
      public?(true)
    end

    attribute :alert_hours, :string do
      public?(true)
    end

    timestamps()
  end

  actions do
    defaults([
      :read,
      :destroy,
      create: [:name, :email, :city, :alert_hours],
      update: [:name, :email, :city, :alert_hours]
    ])
  end

  postgres do
    table "users"
    repo Chronodash.Repo
  end
end
