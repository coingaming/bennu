use Bennu.Component.BlankPage

defrender type: BlankPage,
          design: Design.default_coreui(),
          input: %Input{
            page_title: page_title,
            page_meta_keywords: page_meta_keywords
          },
          context: %RenderContext{socket: %Socket{} = socket} = ctx do
  renderer = fn %Input{main: main} ->
    {flash, %{}} =
      Engine.render(
        context: ctx,
        design: Design.default_coreui(),
        env: %{},
        component: %Flash{
          input: %Flash.Input{},
          output: %Flash.Output{}
        },
        independent_children?: false
      )

    assigns = %{
      socket: socket,
      flash: flash,
      main: main
    }

    ~l"""
    = @flash
    = for x <- @main do
      = x
    """
  end

  {
    renderer,
    %Output{
      page_title: page_title,
      page_meta_keywords: page_meta_keywords
    }
  }
end
