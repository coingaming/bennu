use Bennu.Component

defcomponent Component.Column do
  input do
    title(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    width(
      min_qty: 1,
      max_qty: 1,
      type: Integer
    )

    flex(
      min_qty: 1,
      max_qty: 1,
      type: Atom
    )

    rows(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
  end

  output do
  end
end
