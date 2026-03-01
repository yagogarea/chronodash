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

# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :spark, formatter: ["Ash.Resource": [section_order: [:postgres]]]
config :ash, known_types: [AshPostgres.Timestamptz, AshPostgres.TimestamptzUsec]

config :chronodash,
  ecto_repos: [Chronodash.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [Chronodash.Accounts, Chronodash.Metrics]

# Configures the endpoint
config :chronodash, ChronodashWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ChronodashWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Chronodash.PubSub,
  live_view: [signing_salt: "8bKVsRKc"],
  exclude: [
    # paths: ["/health"],
    hosts: ["localhost", "127.0.0.1"]
  ]

config :chronodash, Chronodash.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: :disabled

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :chronodash, Chronodash.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Polling configuration
config :chronodash, :polling_jobs, [
  %{
    id: :meteosix_wrf_sky_state,
    mfa: {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :sky_state]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_temperature,
    mfa: {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :temperature]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_precipitation,
    mfa:
      {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :precipitation_amount]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_wind,
    mfa: {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :wind]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_humidity,
    mfa:
      {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :relative_humidity]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_clouds,
    mfa:
      {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :cloud_area_fraction]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_pressure,
    mfa:
      {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast,
       [{43.37, -8.42}, :air_pressure_at_sea_level]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  },
  %{
    id: :meteosix_wrf_snow,
    mfa: {Chronodash.DataSource.MeteoSIX.WRF, :get_forecast, [{43.37, -8.42}, :snow_level]},
    rate: :timer.hours(6),
    metadata: %{source: "meteosix"}
  }
]

# Alerts configuration
config :chronodash, :alerts,
  rules: [],
  channels: %{}

# Finch configuration
config :chronodash, :http_client, Chronodash.HttpClient.Finch

config :chronodash, :default_http_client_config,
  name: Chronodash.Finch,
  pools: %{
    default: [
      conn_opts: [
        transport_opts: [
          verify: :verify_peer
        ]
      ]
    ]
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
