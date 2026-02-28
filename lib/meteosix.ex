defmodule MeteoSIX do
  @moduledoc """
  Base module for MeteoSIX API v5 integration.
  Provides shared configuration and request logic.
  """
  alias Chronodash.HttpClient

  def config do
    Application.get_env(:chronodash, :meteosix)
  end

  def base_url, do: config()[:base_url]
  def api_key, do: config()[:api_key]

  @doc """
  Performs a GET request to MeteoSIX with common parameters.
  """
  def request(endpoint, params \\ [], opts \\ []) do
    url = "#{base_url()}/#{endpoint}"

    common_params = [
      API_KEY: api_key(),
      format: "application/json",
      exceptionsFormat: "application/json"
    ]

    final_params =
      common_params
      |> Keyword.merge(params)
      |> Enum.reject(fn {_, v} -> is_nil(v) end)

    parse_request(HttpClient.get(url, [], Keyword.put(opts, :params, final_params)))
  end

  defp parse_request({:ok, %{"status" => "200", "body" => data}}), do: {:ok, data}

  defp parse_request({:error, %{"status" => status, "message" => message}}),
    do: {:error, "#{status}: #{message}"}

  defp parse_request({:error, reason}), do: {:error, reason}
end
