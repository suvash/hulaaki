defmodule Hulaaki.Transport do
  @type socket :: any
  # @type port :: post_integer
  @type packet :: any

  @callback connect(host :: binary, port :: port, opts :: keyword, timeout :: pos_integer) ::
              {:ok, Socket} | {:error, any}
  @callback send(socket :: socket, packet :: packet) :: :ok | {:error, any}
  @callback close(socket :: socket) :: :ok | {:error, any}
  @callback set_active_once(socket :: socket) :: :ok | {:error, any}
  @callback packet_message() :: atom()
  @callback closing_message() :: atom()
end
