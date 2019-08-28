use Bennu.Component

defcomponent Markdown do
  input do
    markdown(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )
  end

  output do
  end
end
