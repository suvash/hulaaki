defmodule Hulaaki.Client do
  defmacro __using__(_) do
    quote location: :keep do
      use GenEvent
      alias Hulaaki.Message

      def start(initial_state) do
        {:ok, manager_pid} = GenEvent.start_link
        GenEvent.add_handler(manager_pid, __MODULE__, initial_state)
        {:ok, manager_pid}
      end

      def handle_event(event = %Message.ConnAck{}, state) do
        on_connect(event, state)
        {:ok, state}
      end

      def handle_event(event, state) do   # Remove eventually
        on_event(event, state)
        {:ok, state}
      end

      def on_event(event, state)
      def on_connect(event, state)        # Remove eventually

      defoverridable [on_event: 2, on_connect: 2]
    end
  end
end
