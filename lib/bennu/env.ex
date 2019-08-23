defmodule Bennu.Env do
  @type t :: %__MODULE__{
          name: String.t(),
          type: module
        }
  @enforce_keys [:name, :type]
  defstruct @enforce_keys
end
