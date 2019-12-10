defmodule Bennu.Design.Material do
  defstruct []
end

defimpl Bennu.Design, for: Bennu.Design.Material do
  def parent(_) do
    nil
  end
end
