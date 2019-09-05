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
      type: Any
    )

    right(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )

    bottom(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
  end

  output do
  end
end
