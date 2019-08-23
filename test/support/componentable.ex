use Bennu.Component

defcomponent C0 do
  input do
  end

  output do
    foo(
      min_qty: 1,
      max_qty: nil,
      type: Integer
    )
  end
end

defcomponent C1 do
  input do
    bar(
      min_qty: 1,
      max_qty: nil,
      type: Integer
    )
  end

  output do
  end
end

defcomponent C2 do
  input do
    c1(
      min_qty: 1,
      max_qty: nil,
      type: C1
    )
  end

  output do
  end
end

defcomponent C3 do
  input do
    c0(
      min_qty: 1,
      max_qty: nil,
      type: C0
    )
  end

  output do
  end
end

defcomponent C4 do
  input do
    buz(
      min_qty: 1,
      max_qty: 2,
      type: Integer
    )
  end

  output do
  end
end

defcomponent C5 do
  input do
    buf(
      min_qty: 1,
      max_qty: 1,
      type: Integer
    )
  end

  output do
    bif(
      min_qty: 1,
      max_qty: 1,
      type: Integer
    )
  end
end
