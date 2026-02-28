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
