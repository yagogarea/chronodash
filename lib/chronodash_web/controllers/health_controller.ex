defmodule ChronodashWeb.HealthController do
  use ChronodashWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
