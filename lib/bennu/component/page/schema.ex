use Bennu.Component

defcomponent Component.Page do
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

    header(
      min_qty: nil,
      max_qty: 1,
      type: PageHeader
    )

    sidebar(
      min_qty: nil,
      max_qty: 1,
      type: PageSidebar
    )

    breadcrumb(
      min_qty: nil,
      max_qty: 1,
      type: Breadcrumb
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
