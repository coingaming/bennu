use Bennu.Component

defcomponent Component.NavLink do
  input do
    src(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    text(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    icon(
      min_qty: nil,
      max_qty: 1,
      type: Atom
    )

    active(
      min_qty: nil,
      max_qty: 1,
      type: Any
    )
  end

  output do
  end
end
