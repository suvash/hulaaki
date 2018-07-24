defmodule Hulaaki.Transport.WebSocket do
  alias :gun, as: Gun

  @behaviour Hulaaki.Transport

  def connect(host, port, opts, timeout) do
    {path, opts} = opts |> Keyword.pop(:path, "/")
    {headers, opts} = opts |> Keyword.pop(:headers, [])

    opts =
      Enum.into(opts, %{})
      |> Map.put(:ws_opts, %{protocols: [{"mqtt", __MODULE__.Helper}]})

    with {:ok, conn} <- Gun.open(host, port, opts),
         {:ok, _protocol} <- Gun.await_up(conn, timeout),
         _stream_ref <- Gun.ws_upgrade(conn, path, headers) do
      await_upgrade(timeout)
    else
      error -> error
    end
  end

  defp await_upgrade(timeout) do
    receive do
      {:gun_upgrade, conn, _, _, _} ->
        {:ok, conn}

      {:gun_response, _, _, _, status, headers} ->
        {:error, {:ws_upgrade_failed, status, headers}}

      {:gun_error, _, _, reason} ->
        {:error, reason}

      _message ->
        await_upgrade(timeout)
    after
      timeout -> {:error, :timeout}
    end
  end

  def send(conn, packet) do
    Gun.ws_send(conn, {:binary, packet})
  end

  def close(conn) do
    Gun.close(conn)
  end

  def set_active_once(conn), do: conn
end
