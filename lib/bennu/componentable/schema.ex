defmodule Bennu.Componentable.SchemaKey do
  @type t :: atom
end

defmodule Bennu.Componentable.SchemaValue do
  @type t :: %__MODULE__{
          type: module,
          min_qty: non_neg_integer | nil,
          max_qty: non_neg_integer | nil,
          min: non_neg_integer | nil,
          max: non_neg_integer | nil,
          step: non_neg_integer | nil
        }
  @enforce_keys [:type, :min_qty, :max_qty]
  defstruct [:type, :min_qty, :max_qty, :min, :max, :step]
end

defmodule Bennu.Componentable.Schema do
  alias Bennu.Componentable.SchemaKey
  alias Bennu.Componentable.SchemaValue
  @type t :: %{SchemaKey.t() => SchemaValue.t()}
end
