use Bennu.Component.Card

defrender type: Card,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{socket: socket} do
  renderer = fn %Input{header: mheader, body: body, footer: mfooter} ->
    assigns = %{
      socket: %Socket{} = socket,
      header: List.first(mheader),
      body: body,
      footer: List.first(mfooter)
    }

    ~l"""
    .card
      = if @header do
        .card-header
          = for x <- @header do
            = if is_binary(x) do
              strong.mr-3 = x
            - else
                = x
      .card-body
        = for x <- @body do
          = x
      = if @footer do
        .card-footer
          = for x <- @footer do
            = x
    """
  end

  {renderer, %Output{}}
end
