use Bennu.Component

defcomponent Component.PageSidebar do
  input do
    title(
      min_qty: nil,
      max_qty: 1,
      type: Component.NavLink
    )

    links(
      min_qty: 1,
      max_qty: nil,
      type: Component.NavLink
    )
  end

  output do
    # bool
    page_sidebar_exists(
      min_qty: 1,
      max_qty: 1,
      type: Atom
    )
  end
end
