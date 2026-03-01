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
      Chronodash.Polling.Scheduler,
      # Alerting Services
      Chronodash.Alerting.Manager
    ]

    Chronodash.Release.create_and_migrate()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chronodash.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        {:ok, pid}

      error ->
        error
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChronodashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
