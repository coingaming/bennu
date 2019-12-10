defmodule Bennu.Design.Bootstrap do
  defstruct []
end

defimpl Bennu.Design, for: Bennu.Design.Bootstrap do
  def parent(_) do
    nil
  end
end
