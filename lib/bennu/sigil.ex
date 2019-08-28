defmodule Bennu.Sigil do
  defmacro sigil_m(x, _) do
    quote location: :keep do
      %Bennu.Component.Markdown{
        input: %Bennu.Component.Markdown.Input{markdown: [unquote(x)]},
        output: %Bennu.Component.Markdown.Output{}
      }
    end
  end
end
