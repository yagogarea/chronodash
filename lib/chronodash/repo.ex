defmodule Chronodash.Repo do
  use AshPostgres.Repo,
    otp_app: :chronodash
end
