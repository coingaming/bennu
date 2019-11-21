use Bennu.Component

defcomponent Component.GridColumn do
  input do
    content(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
    width(
      min_qty: nil,
      max_qty: 1,
      step: 1,
      min: 1,
      max: 12,
      type: Integer
    )
    phone_width(
      min_qty: nil,
      max_qty: 1,
      step: 1,
      min: 1,
      max: 4,
      type: Range
    )
    tablet_width(
      min_qty: nil,
      max_qty: 1,
      step: 1,
      min: 1,
      max: 6,
      type: Range
    )
    desktop_width(
      min_qty: nil,
      max_qty: 1,
      step: 1,
      min: 1,
      max: 12,
      type: Range
    )
  end

  output do
  end
end
