defmodule Chronodash.Repo do
  use Ecto.Repo,
    otp_app: :chronodash,
    adapter: Ecto.Adapters.Postgres
end
