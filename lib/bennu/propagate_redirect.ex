defmodule Bennu.PropagateRedirect do
  defmacro __using__(_) do
    quote location: :keep do
      defp propagate_redirect(
             %Phoenix.LiveView.Socket{root_pid: nil} = socket,
             params
           ) do
        {:stop, Phoenix.LiveView.redirect(socket, params)}
      end

      defp propagate_redirect(
             %Phoenix.LiveView.Socket{root_pid: pid} = socket,
             params
           ) do
        _ = send(pid, {:propagate_redirect, params})
        socket
      end

      def handle_info(
            {:propagate_redirect, params},
            %Phoenix.LiveView.Socket{root_pid: nil} = socket
          ) do
        {:stop, Phoenix.LiveView.redirect(socket, params)}
      end

      def handle_info(
            {:propagate_redirect, _} = msg,
            %Phoenix.LiveView.Socket{root_pid: pid} = socket
          ) do
        _ = send(pid, msg)
        {:noreply, socket}
      end
    end
  end
end
