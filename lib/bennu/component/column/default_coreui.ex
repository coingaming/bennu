use Bennu.Component.Column

defrender type: Column,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{rows: rows} ->
    assigns = %{rows: rows, socket: socket}

    ~l"""
    .col
      = for x <- @rows do
        .row
          = x
    """
  end

  {renderer, %Output{}}
end
