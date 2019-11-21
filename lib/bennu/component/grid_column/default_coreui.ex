use Bennu.Component.GridColumn

defrender type: GridColumn,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{content: content} ->
    assigns = %{content: content, socket: socket}

    ~l"""
    .col
      = for x <- @content do
        = x
    """
  end

  {renderer, %Output{}}
end
