use Bennu.Component

defcomponent Component.Column do
  input do
    width(
      min_qty: 1,
      max_qty: 1,
      type: Integer
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
