defmodule ListSchema do
  defstruct [:schema]
end

defimpl Bennu.Schema, for: ListSchema do
  def validate(%ListSchema{schema: item_schema} = schema, [item | tail]) do
    Bennu.Schema.validate(item_schema, item) && validate(schema, tail)
  end

  def get(_, data, []) do
    data
  end

  def get(_, data, [index]) when is_integer(index) do
    Enum.at(data, index)
  end

  def get(%ListSchema{schema: schema}, data, [index | remaining_path]) when is_integer(index) do
    Bennu.Schema.get(schema, Enum.at(data, index), remaining_path)
  end

  def put(_, _, [], value) do
    value
  end

  def put(_, data, [index], value) when is_integer(index) do
    List.replace_at(data, index, value)
  end

  def put(%ListSchema{schema: schema}, data, [index | remaining_path], value)
      when is_integer(index) do
    List.replace_at(
      data,
      index,
      Bennu.Schema.put(schema, Enum.at(data, index), remaining_path, value)
    )
  end
end
