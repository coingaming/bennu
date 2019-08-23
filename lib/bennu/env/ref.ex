defmodule Bennu.Env.Ref do
  require Bennu.Env.OnDuplicate.Items, as: OnDuplicate

  @type t :: %__MODULE__{
          key: String.t(),
          on_duplicate: Bennu.Env.OnDuplicate.Meta.t()
        }
  @enforce_keys [:key]
  defstruct key: nil,
            on_duplicate: OnDuplicate.raise()
end
