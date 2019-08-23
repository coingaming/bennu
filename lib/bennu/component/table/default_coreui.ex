use Bennu.Component.Table

defrender type: Table,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{} do
  renderer = fn %Input{header: header, rows: rows} ->
    assigns = %{header: List.first(header), rows: rows}

    ~l"""
    table.table.table-responsive-sm.table-borderless.table-striped
      = if @header do
        thead
          tr
            = for x <- @header do
              th = x
      tbody
        = for xs <- @rows do
          tr
            = for x <- xs do
              td = x
    """
  end

  {renderer, %Output{}}
end
