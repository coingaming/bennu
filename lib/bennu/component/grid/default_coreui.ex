use Bennu.Component.Grid

defrender type: Grid,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{rows: rows} ->
    assigns = %{rows: rows, socket: socket}

    ~l"""
    .container
      = for x <- @rows do
        = x
    """
  end

  {renderer, %Output{}}
end
