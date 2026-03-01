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
