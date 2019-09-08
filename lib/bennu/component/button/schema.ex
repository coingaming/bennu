use Bennu.Component

defcomponent Component.Button do
  input do
    form_name(
      min_qty: nil,
      max_qty: 1,
      type: BitString
    )

    href(
      min_qty: nil,
      max_qty: 1,
      type: BitString
    )

    onclick(
      min_qty: nil,
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

    bs_color(
      min_qty: nil,
      max_qty: 1,
      type: Atom
    )
  end

  output do
  end
end
