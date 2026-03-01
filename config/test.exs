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

import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
if config_env() != :test do
  config :chronodash, Chronodash.Repo,
    password:
      System.get_env("DB_PASSWORD") || raise("DB_PASSWORD environment variable is not set")
end

config :chronodash, Chronodash.Repo,
  username: "postgres",
  password: "postgres",
  database: "chronodash_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :ash, disable_async?: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chronodash, ChronodashWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PHMyKQ3dIA5NaOtzhxPjTfm2+5IG/5hNAkH4xlJoBhz7GjftpH0YPl2Q5EbEOHOl",
  server: false

# In test we don't send emails
config :chronodash, Chronodash.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Add mock HTTP client for testing
config :chronodash, :http_client, Chronodash.HttpClient.Mock
