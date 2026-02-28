defmodule Chronodash.HttpClient do
  @moduledoc """
  Behaviour for HTTP clients.
  """

  @http_client Application.compile_env(
                 :chronodash,
                 :http_client,
                 Chronodash.HttpClient.Finch
               )

  # ============================================================================
  # Callbacks
  # ============================================================================

  @callback get(url :: String.t(), headers :: list(), opts :: keyword()) ::
              {:ok, %{status: integer(), body: any()}} | {:error, any()}

  @callback post(url :: String.t(), body :: any(), headers :: list(), opts :: keyword()) ::
              {:ok, %{status: integer(), body: any()}} | {:error, any()}

  @callback request(
              method :: atom(),
              url :: String.t(),
              headers :: list(),
              body :: any(),
              opts :: keyword()
            ) ::
              {:ok, %{status: integer(), body: any()}} | {:error, any()}

  # ============================================================================
  # Public API
  # ============================================================================

  def get(url, headers \\ [], opts \\ []) do
    impl().get(url, headers, with_defaults(opts))
  end

  def post(url, body, headers \\ [], opts \\ []) do
    impl().post(url, body, headers, with_defaults(opts))
  end

  def request(method, url, headers \\ [], body \\ nil, opts \\ []) do
    impl().request(method, url, headers, body, with_defaults(opts))
  end

  # ============================================================================
  # Private API
  # ============================================================================

  defp impl, do: @http_client

  defp with_defaults(opts) do
    default_opts = Application.get_env(:chronodash, :http_client_default_opts, [])
    Keyword.merge(default_opts, opts)
  end
end
