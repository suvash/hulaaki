defmodule Hulaaki.Client do
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      alias Hulaaki.Connection
      alias Hulaaki.Message

      def start(initial_state) do
        {:ok, connection_pid} = Connection.start_link(self())
        state = Map.merge(%{connection: connection_pid}, initial_state)

        GenServer.start_link(__MODULE__, state)
      end

      def connect(pid, opts) do
        GenServer.call(pid, {:connect, opts})
      end

      def handle_call({:connect, opts}, _from, state) do
        client_id     = opts |> Keyword.fetch! :client_id
        username      = opts |> Keyword.get :username, ""
        password      = opts |> Keyword.get :password, ""
        will_topic    = opts |> Keyword.get :will_topic, ""
        will_message  = opts |> Keyword.get :will_message, ""
        will_qos      = opts |> Keyword.get :will_qos, 0
        will_retain   = opts |> Keyword.get :will_retain, 0
        clean_session = opts |> Keyword.get :clean_session, 1
        keep_alive    = opts |> Keyword.get :keep_alive, 100

        message = Message.connect(client_id, username, password,
                                  will_topic, will_message, will_qos,
                                  will_retain, clean_session, keep_alive)

        state.connection |> Connection.connect message

         {:reply, :ok, state}
      end

      def handle_info(%Message.ConnAck{} = message, state) do
        on_connect(message, state)
        {:ok, state}
      end

      def on_connect(event, state)

      defoverridable [on_connect: 2]
    end
  end
end
