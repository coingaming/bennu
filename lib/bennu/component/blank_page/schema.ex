use Bennu.Component

defcomponent Component.BlankPage do
  input do
    page_title(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    page_meta_keywords(
      min_qty: nil,
      max_qty: nil,
      type: BitString
    )

    main(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
  end

  output do
    page_title(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    page_meta_keywords(
      min_qty: nil,
      max_qty: nil,
      type: BitString
    )
  end
end
