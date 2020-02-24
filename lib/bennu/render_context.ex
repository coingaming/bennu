defmodule Bennu.RenderContext do
  @type t :: %__MODULE__{
          parent: t | nil,
          component: term,
          name: atom | nil,
          index: non_neg_integer | nil,
          conn: Plug.Conn.t(),
          socket: %Phoenix.LiveView.Socket{},
          path: [String.t()]
        }
  @enforce_keys [
    :parent,
    :component,
    :name,
    :index,
    :conn,
    :socket,
    :path
  ]
  defstruct @enforce_keys
end
