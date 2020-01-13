defmodule TextSchema do
  defstruct []
end

defimpl Bennu.Schema, for: TextSchema do
  def validate(_, data) when is_binary(data) do
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
