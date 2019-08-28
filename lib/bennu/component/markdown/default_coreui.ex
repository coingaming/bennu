use Bennu.Component.Markdown

defrender type: Markdown,
          design: Design.default_coreui(),
          input: %Input{markdown: [markdown]},
          context: %RenderContext{} do
  renderer = fn %Input{} ->
    {:ok, html, _} =
      markdown
      |> Earmark.as_html()

    Phoenix.HTML.raw(html)
  end

  {renderer, %Output{}}
end
