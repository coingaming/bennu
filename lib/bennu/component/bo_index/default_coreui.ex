use Bennu.Component.BOIndex

defrender type: BOIndex,
          design: Design.default_coreui(),
          input: %Input{title: [title]},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{content: content} ->
    assigns = %{
      socket: socket,
      title: title,
      content: content
    }

    ~l"""
    .center
      .row.text-center
        .col-lg-4.offset-lg-4.col-md-6.offset-md-3.col-sm-12
          h1 = @title

      .card
        .card-header
          h3 Here you can
        .card-body.lead
          = @content
        .card-footer.text-muted.text-center.lead <-- menu is on the left <--
    """
  end

  {renderer, %Output{}}
end
