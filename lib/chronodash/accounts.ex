defmodule Chronodash.Accounts do
  @moduledoc """
  Accounts domain for Chronodash. Contains resources related to user accounts and preferences.
  """

  use Ash.Domain,
    otp_app: :chronodash

  resources do
    resource(Chronodash.Accounts.User)
  end
end
