defmodule ChronodashWeb.UserController do
  use ChronodashWeb, :controller

  alias Chronodash.Accounts.User
  alias ChronodashWeb.AshController

  # ============================================================================
  # Public API
  # ============================================================================

  def index(conn, _params),
    do: AshController.index(conn, User)

  def show(conn, %{"id" => id}),
    do: AshController.show(conn, User, id)

  def create(conn, params),
    do: AshController.create(conn, User, params)

  def update(conn, %{"id" => id} = params),
    do: AshController.update(conn, User, id, params)

  def delete(conn, %{"id" => id}),
    do: AshController.delete(conn, User, id)
end
