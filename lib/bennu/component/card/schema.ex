use Bennu.Component

defcomponent Component.Card do
  input do
    header(
      min_qty: nil,
      max_qty: 1,
      type: ComponentList
    )

    body(
      min_qty: 1,
      max_qty: nil,
      type: Any
    )

    footer(
      min_qty: nil,
      max_qty: 1,
      type: ComponentList
    )
  end

  output do
  end
end
