use Bennu.Component.Page

defrender type: Page,
          design: Design.default_coreui(),
          input: %Input{
            page_title: page_title,
            page_meta_keywords: page_meta_keywords
          },
          context: %RenderContext{socket: %Socket{} = socket} = ctx do
  renderer = fn %Input{
                  header: mheader,
                  sidebar: msidebar,
                  breadcrumb: mbreadcrumb,
                  main: main
                } ->
    {flash, %{}} =
      Engine.render(
        context: ctx,
        design: Design.default_coreui(),
        env: %{},
        component: %Flash{},
        independent_children?: false
      )

    assigns = %{
      socket: socket,
      header: List.first(mheader),
      sidebar: List.first(msidebar),
      breadcrumb: List.first(mbreadcrumb),
      flash: flash,
      main: main
    }

    ~l"""
    = @header
    .app-body
      = @sidebar
      main.main
        = @breadcrumb
        .container-fluid
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
