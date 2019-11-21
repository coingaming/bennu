use Bennu.Component

defrender type: C0,
          design: Design.bootstrap(),
          input: %C0.Input{},
          context: %RenderContext{} do
  renderer = fn %C0.Input{} ->
    assigns = %{}

    ~l"""
    .c0
    """
  end

  {renderer, %C0.Output{foo: [1, 2, 3]}}
end

defrender type: C1,
          design: Design.bootstrap(),
          input: %C1.Input{bar: bar},
          context: %RenderContext{} do
  renderer = fn %C1.Input{} ->
    assigns = %{sum: Enum.sum(bar)}

    ~l"""
    .c1 = @sum
    """
  end

  {renderer, %C1.Output{}}
end

defrender type: C2,
          design: Design.bootstrap(),
          input: %C2.Input{},
          context: %RenderContext{} do
  renderer = fn %C2.Input{c1: [_ | _] = c1} ->
    assigns = %{c1: c1}

    ~l"""
    .c2
      = for x <- @c1 do
        = x
    """
  end

  {renderer, %C2.Output{}}
end

defrender type: C3,
          design: Design.bootstrap(),
          input: %C3.Input{},
          context: %RenderContext{} do
  renderer = fn %C3.Input{c0: [_ | _] = c0} ->
    assigns = %{c0: c0}

    ~l"""
    .c3
      = for x <- @c0 do
        = x
    """
  end

  {renderer, %C3.Output{}}
end

defrender type: C4,
          design: Design.bootstrap(),
          input: %C4.Input{buz: buz},
          context: %RenderContext{} do
  renderer = fn %C4.Input{} ->
    assigns = %{sum: Enum.sum(buz)}

    ~l"""
    .c4 = @sum
    """
  end

  {renderer, %C4.Output{}}
end

defrender type: C5,
          design: Design.bootstrap(),
          input: %C5.Input{buf: buf},
          context: %RenderContext{} do
  renderer = fn %C5.Input{} ->
    assigns = %{buf: buf}

    ~l"""
    .c5 = @buf
    """
  end

  {renderer, %C5.Output{bif: [buf + 1]}}
end
