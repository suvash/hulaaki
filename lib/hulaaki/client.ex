defmodule Hulaaki.Client do
  defmacro __using__(_) do
    quote location: :keep do
      use GenEvent

      def start(initial_state) do
        {:ok, manager_pid} = GenEvent.start_link
        GenEvent.add_handler(manager_pid, __MODULE__, initial_state)
        {:ok, manager_pid}
      end

      def handle_event(event, state) do
        on_event(event, state)
        {:ok, state}
      end

      def on_event(event, state)

      defoverridable [on_event: 2]
    end
  end
end
