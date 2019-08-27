use Bennu.Component.PageSidebar

defrender type: PageSidebar,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{title: title, links: links} ->
    assigns = %{
      socket: socket,
      title: List.first(title),
      links: links
    }

    ~l"""
    .sidebar
      nav.sidebar-nav
        ul.nav
          = if @title do
            li.nav-title = @title
          = for x <- @links do
            li.nav-item = x
      button.sidebar-minimizer.brand-minimizer type="button"
    """
  end

  {renderer, %Output{page_sidebar_exists: [true]}}
end
