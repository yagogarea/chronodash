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

defmodule MeteoSIX.Operations do
  @moduledoc """
  Handles location-related operations for MeteoSIX.
  """
  alias MeteoSIX

  @doc """
  Finds places by name using MeteoSIX's findPlaces endpoint.
  """
  def find_places(query, opts \\ []) do
    params = [
      location: query,
      types: opts[:types],
      lang: opts[:lang] || "gl"
    ]

    MeteoSIX.request("findPlaces", params, opts)
  end
end
