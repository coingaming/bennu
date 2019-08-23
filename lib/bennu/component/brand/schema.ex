use Bennu.Component

defcomponent Component.Brand do
  input do
    src_full(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    src_min(
      min_qty: nil,
      max_qty: 1,
      type: BitString
    )
  end

  output do
  end
end
