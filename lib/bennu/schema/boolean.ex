defmodule BooleanSchema do
  defstruct []
end

defimpl Bennu.Schema, for: BooleanSchema do
  def validate(_, data) when is_boolean(data) do
    true
  end

  def validate(_, _) do
    false
  end

  def get(_, data, []) do
    data
  end

  def put(_, _, [], value) do
    value
  end
end
