defmodule Bennu.PropagateRedirect do
  defmacro __using__(_) do
    quote location: :keep do
      require Phoenix.LiveView.Socket, as: Socket

      defp propagate_redirect(%Socket{parent_pid: nil} = socket, params) do
        {:stop, Phoenix.LiveView.redirect(socket, params)}
      end

      defp propagate_redirect(%Socket{parent_pid: pid} = socket, params) do
        _ = send(pid, {:propagate_redirect, params})
        socket
      end

      def handle_info({:propagate_redirect, params}, %Socket{parent_pid: nil} = socket) do
        {:stop, Phoenix.LiveView.redirect(socket, params)}
      end

      def handle_info({:propagate_redirect, _} = msg, %Socket{parent_pid: pid} = socket) do
        _ = send(pid, msg)
        {:noreply, socket}
      end
    end
  end
end
