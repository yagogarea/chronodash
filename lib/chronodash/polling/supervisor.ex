defmodule Chronodash.Polling.Supervisor do
  @moduledoc """
  A dynamic supervisor to manage individual polling workers.
  """
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Adds a new polling job to the supervisor.
  """
  def start_child(opts) do
    spec = {Chronodash.Polling.Worker, opts}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
