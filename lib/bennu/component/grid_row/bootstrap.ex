use Bennu.Component.GridRow

defrender type: GridRow,
          design: Design.bootstrap(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{columns: columns} ->
    assigns = %{columns: columns, socket: socket}

    ~l"""
    .row
      = for x <- @columns do
        = x
    """
  end

  {renderer, %Output{}}
end
