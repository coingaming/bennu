defmodule Bennu.RenderContext do
  @type t :: %__MODULE__{
          parent: t,
          component: term,
          name: atom,
          index: non_neg_integer,
          conn: Plug.Conn.t(),
          socket: Phoenix.LiveView.Socket.t(),
          base_path: [String.t()],
          path: [String.t()]
        }
  @enforce_keys [
    :parent,
    :component,
    :name,
    :index,
    :conn,
    :socket,
    :base_path,
    :path
  ]
  defstruct @enforce_keys
end
