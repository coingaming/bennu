use Bennu.Component

defcomponent Component.PageHeader do
  input do
    brand(
      min_qty: 1,
      max_qty: 1,
      type: Component.Brand
    )

    # bool
    page_sidebar_exists(
      min_qty: nil,
      max_qty: 1,
      type: Atom
    )

    left(
      min_qty: nil,
      max_qty: nil,
      type: Component.NavLink
    )

    right(
      min_qty: nil,
      max_qty: nil,
      type: Component.NavLink
    )
  end

  output do
  end
end
