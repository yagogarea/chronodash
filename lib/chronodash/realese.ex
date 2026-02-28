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
