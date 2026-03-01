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

defmodule Chronodash.Release do
  @moduledoc """
  Tasks for running migrations in a release.
  """
  @app :chronodash
  # ============================================================================
  # Public API
  # ============================================================================

  @doc """
  Run all pending migrations.
  """
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc """
  Create database and run migrations.
  """
  def create_and_migrate do
    load_app()

    for repo <- repos() do
      case repo.__adapter__().storage_up(repo.config()) do
        :ok -> :ok
        {:error, :already_up} -> :ok
        {:error, term} -> raise "Failed to create database: #{inspect(term)}"
      end
    end

    migrate()
  end

  @doc """
  Rollback the last migration.
  """
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  # ============================================================================
  # Helper Functions
  # ============================================================================

  defp repos do
    Application.get_env(@app, :ecto_repos, [])
  end

  defp load_app do
    Application.load(@app)
  end
end
