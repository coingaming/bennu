use Bennu.Component.PageHeader

defrender type: PageHeader,
          design: Design.default_coreui(),
          input: %Input{page_sidebar_exists: page_sidebar_exists},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{brand: [brand], left: left, right: right} ->
    assigns = %{
      socket: socket,
      brand: brand,
      page_sidebar_exists: List.first(page_sidebar_exists),
      left: left,
      right: right
    }

    ~l"""
    header.app-header.navbar
      = if @page_sidebar_exists do
        button.navbar-toggler.sidebar-toggler.d-lg-none.mr-auto data-toggle="sidebar-show" type="button"
          span.navbar-toggler-icon
      = @brand
      = if @page_sidebar_exists do
        button.navbar-toggler.sidebar-toggler.d-md-down-none data-toggle="sidebar-lg-show" type="button"
          span.navbar-toggler-icon
      ul.nav.navbar-nav.d-md-down-none
        = for x <- @left do
          li.nav-item.px-3
            = x
      ul.nav.navbar-nav.ml-auto
        = for x <- @right do
          li.nav-item.d-md-down-none
            = x
    """
  end

  {renderer, %Output{}}
end
