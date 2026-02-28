defmodule Chronodash.Polling.Scheduler do
  @moduledoc """
  Reads configured polling jobs and starts them in the Polling Supervisor.
  """
  use GenServer
  require Logger

  alias Chronodash.Polling.Supervisor, as: PollingSupervisor

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    send(self(), :start_jobs)
    {:ok, []}
  end

  @impl true
  def handle_info(:start_jobs, state) do
    jobs = Application.get_env(:chronodash, :polling_jobs, [])

    Enum.each(jobs, fn job ->
      case PollingSupervisor.start_child(job) do
        {:ok, _pid} ->
          Logger.info("Successfully started polling job: #{job.id}")

        {:error, {:already_started, _pid}} ->
          Logger.debug("Polling job #{job.id} already started")

        {:error, reason} ->
          Logger.error("Failed to start polling job #{job.id}: #{inspect(reason)}")
      end
    end)

    {:noreply, state}
  end
end
