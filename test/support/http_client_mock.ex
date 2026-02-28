defmodule Chronodash.HttpClient.Mock do
  @behaviour Chronodash.HttpClient

  def get(_url, _headers, _opts) do
    {:ok, %{status: 200, body: %{"features" => []}}}
  end

  def post(_url, _body, _headers, _opts) do
    {:ok, %{status: 201, body: %{"status" => "created"}}}
  end

  def request(method, _url, _headers, _body, _opts) do
    case method do
      :get -> {:ok, %{status: 200, body: %{"features" => []}}}
      :post -> {:ok, %{status: 201, body: %{"status" => "created"}}}
      _ -> {:ok, %{status: 200, body: %{"features" => []}}}
    end
  end
end
