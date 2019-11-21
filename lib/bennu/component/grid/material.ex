use Bennu.Component.Grid

defrender type: Grid,
          design: Design.material(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{rows: rows} ->
    assigns = %{rows: rows, socket: socket}

    ~l"""
    .mdc-layout-grid
      = for x <- @rows do
        = x
    """
  end

  {renderer, %Output{}}
end
