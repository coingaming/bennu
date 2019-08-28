use Bennu.Component

defcomponent BOIndex do
  input do
    title(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    content(
      min_qty: 1,
      max_qty: 1,
      type: Any
    )
  end

  output do
  end
end
