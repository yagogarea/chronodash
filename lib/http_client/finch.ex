defmodule Chronodash.HttpClient.Finch do
  @moduledoc """
  Finch-based implementation of the `Chronodash.HttpClient` behaviour.
  """
  @behaviour Chronodash.HttpClient

  @finch_name Chronodash.Finch

  # ============================================================================
  # Public API
  # ============================================================================

  def get(url, headers \\ [], opts \\ []) do
    do_request(:get, url, headers, nil, opts)
  end

  def post(url, body, headers \\ [], opts \\ []) do
    do_request(:post, url, headers, body, opts)
  end

  def request(method, url, headers \\ [], body \\ nil, opts \\ []) do
    do_request(method, url, headers, body, opts)
  end

  # ============================================================================
  # Helper functions
  # ============================================================================

  defp do_request(method, url, headers, body, opts) do
    req_opts = [
      method: method,
      url: url,
      headers: headers,
      body: body,
      finch: @finch_name
    ]

    # Combine with provided options
    final_opts = Keyword.merge(req_opts, opts)

    case Req.request(final_opts) do
      {:ok, %Req.Response{status: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
