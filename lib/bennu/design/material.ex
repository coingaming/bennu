defmodule Material do
  defstruct []
end

defimpl Bennu.Design, for: Material do
  def parent(_) do
    nil
  end

  def layout(_) do
    nil
  end

  def assets(_) do
    nil
  end
end
