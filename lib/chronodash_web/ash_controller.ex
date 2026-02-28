defmodule ChronodashWeb.AshController do
  import Plug.Conn
  import Phoenix.Controller

  # ============================================================================
  # Public API
  # ============================================================================

  def index(conn, resource) do
    case Ash.read(resource) do
      {:ok, results} -> json(conn, results)
      {:error, error} -> handle_error(conn, error)
    end
  end

  def show(conn, resource, id) do
    case Ash.get(resource, id) do
      {:ok, record} -> json(conn, record)
      {:error, error} -> handle_error(conn, error)
    end
  end

  def create(conn, resource, params) do
    params = Map.drop(params, ["id"])

    case Ash.create(resource, params) do
      {:ok, record} ->
        conn
        |> put_status(:created)
        |> json(record)

      {:error, error} ->
        handle_error(conn, error)
    end
  end

  def update(conn, resource, id, params) do
    params = Map.drop(params, ["id"])

    with {:ok, record} <- Ash.get(resource, id),
         {:ok, updated} <- Ash.update(record, params) do
      json(conn, updated)
    else
      {:error, error} -> handle_error(conn, error)
    end
  end

  def delete(conn, resource, id) do
    with {:ok, record} <- Ash.get(resource, id),
         :ok <- Ash.destroy(record) do
      send_resp(conn, :no_content, "")
    else
      {:error, error} -> handle_error(conn, error)
    end
  end

  # ============================================================================
  # Error handling
  # ============================================================================

  defp handle_error(conn, %Ash.Error.Query.NotFound{}) do
    conn |> put_status(:not_found) |> json(%{error: "Not Found"})
  end

  defp handle_error(conn, %Ash.Error.Invalid{errors: errors}) do
    if not_found?(errors) do
      conn |> put_status(:not_found) |> json(%{error: "Not Found"})
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: format_errors(errors)})
    end
  end

  defp handle_error(conn, error) do
    status = if has_not_found?(error), do: :not_found, else: :bad_request
    conn |> put_status(status) |> json(%{error: inspect(error)})
  end

  # ============================================================================
  # Helpers
  # ============================================================================

  defp not_found?(errors) do
    Enum.any?(errors, fn
      %Ash.Error.Query.NotFound{} -> true
      %Ash.Error.Invalid.InvalidPrimaryKey{} -> true
      _ -> false
    end)
  end

  defp has_not_found?(%Ash.Error.Invalid{errors: errors}), do: not_found?(errors)
  defp has_not_found?(_), do: false

  defp format_errors(errors) do
    Enum.map(errors, fn
      %Ash.Error.Changes.Required{field: field} ->
        %{field: field, message: "is required"}

      %Ash.Error.Invalid.NoSuchInput{input: input} ->
        %{field: input, message: "is not accepted"}

      err ->
        %{message: inspect(err)}
    end)
  end
end
