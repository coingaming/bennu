defmodule Bennu.RenderContext do
  @type t :: %__MODULE__{
          parent: t | nil,
          component: term,
          name: atom | nil,
          index: non_neg_integer | nil,
          attrs: map
        }
  @enforce_keys [:component]
  defstruct [
    parent: nil,
    component: nil,
    name: nil,
    index: nil,
    attrs: %{},
  ]
end
