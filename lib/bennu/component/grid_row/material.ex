use Bennu.Component.GridRow

defrender type: GridRow,
          design: Design.material(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{columns: columns} ->
    assigns = %{columns: columns, socket: socket}

    ~l"""
    .mdc-layout-grid__inner
      = for x <- @columns do
        = x
    """
  end

  {renderer, %Output{}}
end
