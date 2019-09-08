use Bennu.Component

defcomponent Component.EntityList do
  input do
    title(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    header(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )

    rows(
      min_qty: nil,
      max_qty: nil,
      type: List
    )
  end

  output do
  end
end
