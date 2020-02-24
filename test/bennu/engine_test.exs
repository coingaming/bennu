defmodule Bennu.EngineTest do
  use ExUnit.Case
  use Bennu.Component

  @env_key "article_id"

  setup do
    c0 = %C0{
      input: %C0.Input{},
      output: %C0.Output{foo: %EnvRef{key: @env_key, on_duplicate: OnDuplicate.replace()}}
    }

    c1 = %C1{
      input: %C1.Input{bar: [%EnvRef{key: @env_key}]},
      output: %C1.Output{}
    }

    c2 = %C2{
      input: %C2.Input{
        c1: [c1, c1, c1]
      },
      output: %C2.Output{}
    }

    c3 = %C3{
      input: %C3.Input{
        c0: [c0, c0, c0]
      },
      output: %C3.Output{}
    }

    %{c0: c0, c1: c1, c2: c2, c3: c3}
  end

  test "direct siblings rendering order (C1 depends on C0)", %{c1: %C1{} = c1, c0: %C0{} = c0} do
    cs = [c1, c0]

    [cs, Enum.reverse(cs)]
    |> Enum.each(fn content ->
      component = %GridColumn{
        input: %GridColumn.Input{content: content},
        output: %GridColumn.Output{}
      }

      assert {%Phoenix.LiveView.Rendered{}, %{}, %{}} = default_render(component)
    end)
  end

  test "children rendering order (C2 children depends on C0)", %{c2: %C2{} = c2, c0: %C0{} = c0} do
    cs = [c2, c0]

    [cs, Enum.reverse(cs)]
    |> Enum.each(fn content ->
      component = %GridColumn{
        input: %GridColumn.Input{content: content},
        output: %GridColumn.Output{}
      }

      assert {%Phoenix.LiveView.Rendered{}, %{}, %{}} = default_render(component)
    end)
  end

  test "children rendering order (C1 depends on C3 children)", %{c1: %C1{} = c1, c3: %C3{} = c3} do
    cs = [c1, c3]

    [cs, Enum.reverse(cs)]
    |> Enum.each(fn content ->
      component = %GridColumn{
        input: %GridColumn.Input{content: content},
        output: %GridColumn.Output{}
      }

      assert {%Phoenix.LiveView.Rendered{}, %{}, %{}} = default_render(component)
    end)
  end

  test "children rendering order (C2 children depends on C3 children)", %{
    c2: %C2{} = c2,
    c3: %C3{} = c3
  } do
    cs = [c2, c3]

    [cs, Enum.reverse(cs)]
    |> Enum.each(fn content ->
      component = %GridColumn{
        input: %GridColumn.Input{content: content},
        output: %GridColumn.Output{}
      }

      assert {%Phoenix.LiveView.Rendered{}, %{}, %{}} = default_render(component)
    end)
  end

  test "C4 input field amount is less then min qty" do
    component = %C4{
      input: %C4.Input{buz: []},
      output: %C4.Output{}
    }

    assert_raise RuntimeError,
                 "buz qty=0 for field of type %Bennu.Componentable.SchemaValue{max_qty: 2, min_qty: 1, type: Integer}",
                 fn ->
                   default_render(component)
                 end
  end

  test "C4 input field amount is more then max qty" do
    component = %C4{
      input: %C4.Input{buz: [1, 2, 3]},
      output: %C4.Output{}
    }

    assert_raise RuntimeError,
                 "buz qty=3 for field of type %Bennu.Componentable.SchemaValue{max_qty: 2, min_qty: 1, type: Integer}",
                 fn ->
                   default_render(component)
                 end
  end

  test "C4 input field has wrong type" do
    component = %C4{
      input: %C4.Input{buz: [1.0]},
      output: %C4.Output{}
    }

    assert_raise RuntimeError,
                 "buz expected Elixir.Integer type, but got Elixir.Float for [1.0]",
                 fn ->
                   default_render(component)
                 end
  end

  test "circular dependency in C5" do
    component = %GridColumn{
      input: %GridColumn.Input{
        content: [
          %C5{
            input: %C5.Input{buf: [%EnvRef{key: @env_key}]},
            output: %C5.Output{bif: %EnvRef{key: @env_key}}
          }
        ]
      },
      output: %GridColumn.Output{}
    }

    assert_raise RuntimeError,
                 ~r/dependency on other component/,
                 fn ->
                   default_render(component)
                 end
  end

  defp default_ctx(component) do
    %RenderContext{
      parent: nil,
      component: component,
      name: nil,
      index: nil,
      conn: %Plug.Conn{},
      socket: %Phoenix.LiveView.Socket{},
      path: nil
    }
  end

  defp default_render(component) do
    Engine.render(
      component: component,
      design: Bootstrap,
      context: default_ctx(component),
      env: %{"article_id" => 123},
      independent_children?: false,
      dependency_tree: %{}
    )
  end
end
