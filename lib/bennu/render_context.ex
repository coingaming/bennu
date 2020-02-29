defmodule Bennu.RenderContext do
  @type t :: %__MODULE__{
          parent: t | nil,
          component: term,
          name: atom | nil,
          index: non_neg_integer | nil,
          attrs: map
        }
  @enforce_keys [
    :parent,
    :component,
    :name,
    :index,
    :attrs,
  ]
  defstruct @enforce_keys
end
