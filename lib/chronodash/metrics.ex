defmodule Chronodash.Metrics do
  @moduledoc """
  Metrics domain for Chronodash. Handles weather and maritime observations.
  """

  use Ash.Domain,
    otp_app: :chronodash

  resources do
    resource(Chronodash.Metrics.Location)
    resource(Chronodash.Metrics.Observation)
  end
end
