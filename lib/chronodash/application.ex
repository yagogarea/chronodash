defmodule Chronodash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Chronodash.PromEx,
      ChronodashWeb.Telemetry,
      {Registry, keys: :unique, name: Chronodash.Registry},
      Chronodash.Repo,
      {DNSCluster, query: Application.get_env(:chronodash, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chronodash.PubSub},
      # Start a worker by calling: Chronodash.Worker.start_link(arg)
      # {Chronodash.Worker, arg},
      # Start to serve requests, typically the last entry
      ChronodashWeb.Endpoint,
      {Finch, name: Chronodash.Finch},
      # Polling Services
      Chronodash.Polling.Supervisor,
      Chronodash.Polling.Scheduler
    ]

    Chronodash.Release.create_and_migrate()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chronodash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChronodashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
