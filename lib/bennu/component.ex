defmodule Bennu.Component do
  @moduledoc """
  Provides utilities to implement and work with
  `Bennu.Componentable` and
  `Bennu.Renderable` types
  """

  require Bennu.Componentable, as: Componentable
  require Bennu.Componentable.SchemaValue, as: SchemaValue
  require Bennu.Renderable, as: Renderable
  require Bennu.RenderContext, as: RenderContext
  import Record
  import Meme
  use Defnamed

  @heavy_cache_ttl nil

  # abstract Component data type
  # in reality it's one of %Grid{} | %Column{} | etc
  @type t :: term()

  defmacro __using__(_) do
    quote do
      require Bennu.Engine, as: Engine
      require Bennu.Env.OnDuplicate.Items, as: OnDuplicate
      require Bennu.Env.Ref, as: EnvRef
      require Bennu.RenderContext, as: RenderContext
      require Bennu.Utils, as: Utils
      require unquote(__MODULE__), as: Component

      import unquote(__MODULE__),
        only: [defcomponent: 2, defdesignimpl: 2, trivial_renderer: 1, component: 1]

      alias Component.Grid
      alias Component.GridColumn
      alias Component.GridRow
    end
  end

  @type component :: record(:component, module: module, assigns: map)

  defrecord :component, module: nil, assigns: %{}

  defmacro defcomponent(quoted_type,
             do: {
               :__block__,
               _,
               [
                 {:input, _, [[do: raw_input_ast]]},
                 {:output, _, [[do: raw_output_ast]]}
               ]
             }
           ) do
    {type, []} = Code.eval_quoted(quoted_type, [], __CALLER__)
    input_type = Module.concat(type, "Input")
    output_type = Module.concat(type, "Output")

    [%{} = input_spec, %{} = output_spec] =
      [raw_input_ast, raw_output_ast]
      |> Enum.map(fn code ->
        case code do
          {:__block__, _, xs} when is_list(xs) -> xs
          _ -> [code]
        end
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {{field, _, [spec]}, index}, %{} = acc ->
          false = Map.has_key?(acc, field)
          Map.put_new(acc, field, [{:index, index} | spec])
        end)
      end)

    [%{} = input_schema, %{} = output_schema] =
      [input_spec, output_spec]
      |> Enum.map(fn %{} = full_spec ->
        full_spec
        |> Enum.reduce(%{}, fn {field, spec}, %{} = acc ->
          {%SchemaValue{} = val, []} =
            {:%, [],
             [
               {:__aliases__, [alias: false], [:Bennu, :Componentable, :SchemaValue]},
               {:%{}, [], spec}
             ]}
            |> Code.eval_quoted([], __CALLER__)

          Map.put(acc, field, val)
        end)
      end)

    [enforced_input_schema, enforced_output_schema] =
      [input_schema, output_schema]
      |> Enum.map(fn %{} = spec ->
        spec
        |> Enum.flat_map(fn {k, %SchemaValue{min_qty: min_qty}} ->
          min_qty
          |> case do
            _ when is_integer(min_qty) and min_qty > 0 -> [k]
            _ when min_qty in [0, nil] -> []
          end
        end)
      end)

    type_keys = [
      input:
        quote do
          struct(unquote(input_type))
        end,
      output:
        quote do
          struct(unquote(output_type))
        end
    ]

    enforced_type_keys =
      type_keys
      |> Enum.flat_map(fn
        {k, nil} -> [k]
        {_, _} -> []
      end)

    quote location: :keep do
      defmodule unquote(input_type) do
        #
        # TODO : GENERATE TYPE T PROPERLY???
        #
        @type t :: %__MODULE__{}
        @enforce_keys unquote(enforced_input_schema)
        defstruct unquote(
                    input_schema
                    |> Enum.map(fn
                      {key, %SchemaValue{min_qty: min_qty, type: Integer}}
                      when is_integer(min_qty) and min_qty > 0 ->
                        {key, List.duplicate(0, min_qty)}

                      {key, %SchemaValue{min_qty: min_qty, type: BitString}}
                      when is_integer(min_qty)
                      when min_qty > 0 ->
                        {key, List.duplicate("", min_qty)}

                      {key, %SchemaValue{min_qty: min_qty, type: Atom}}
                      when is_integer(min_qty)
                      when min_qty > 0 ->
                        {key, List.duplicate(false, min_qty)}

                      {key, _} ->
                        {key, []}
                    end)
                  )
      end

      defmodule unquote(output_type) do
        #
        # TODO : GENERATE TYPE T PROPERLY???
        #
        @type t :: %__MODULE__{}
        @enforce_keys unquote(enforced_output_schema)
        defstruct unquote(
                    output_spec
                    |> Map.keys()
                    |> Enum.map(&{&1, []})
                  )
      end

      defmodule unquote(type) do
        @type t :: %__MODULE__{
                input: unquote(input_type).t(),
                output: unquote(output_type).t()
              }

        @enforce_keys unquote(enforced_type_keys)
        defstruct unquote(type_keys)

        defmacro __using__(_) do
          type = unquote(type)
          input_type = unquote(input_type)
          output_type = unquote(output_type)

          last_chunk =
            [
              type
              |> Module.split()
              |> List.last()
              |> String.to_atom()
            ]
            |> Module.concat()

          quote location: :keep do
            use Bennu.Component
            require Plug.Conn, as: Conn
            require unquote(input_type), as: Input
            require unquote(output_type), as: Output
            require unquote(type), as: unquote(last_chunk)
          end
        end
      end

      defimpl Bennu.Componentable, for: unquote(type) do
        def input_schema(%unquote(type){}) do
          unquote(input_schema |> Macro.escape())
        end

        def output_schema(%unquote(type){}) do
          unquote(output_schema |> Macro.escape())
        end
      end
    end
  end

  defmacro defdesignimpl([type: quoted_type, design: quoted_design], do: code) do
    {comp_type, []} = Code.eval_quoted(quoted_type, [], __CALLER__)
    {design, []} = Code.eval_quoted(quoted_design, [], __CALLER__)
    #
    # TODO : try-catch with more detailed reraise
    #
    :ok = Type.assert_exist!(comp_type)
    :ok = Protocol.assert_impl!(Componentable, comp_type)

    type = Bennu.Utils.comp_design_module(comp_type, design)

    quote do
      defmodule unquote(type) do
        @enforce_keys []
        defstruct @enforce_keys
      end

      defimpl Bennu.Renderable, for: unquote(type) do
        unquote(code)
      end
    end
  end

  defn input_schema(it: it) do
    Componentable.input_schema(it)
  end

  defn output_schema(it: it) do
    Componentable.output_schema(it)
  end

  defn evaluate(
         context: %RenderContext{} = ctx,
         component: component,
         design: design,
         input: input
       ) do
    component
    |> Type.type_of()
    |> new_renderable(design)
    |> Renderable.evaluate(input, ctx)
  end

  defmacron trivial_renderer(for: mod, context: ctx, design: design, component: component) do
    quote location: :keep do
      {html, %{}, %{}} =
        Bennu.Engine.render(
          context: unquote(ctx),
          design: unquote(design),
          env: %{},
          component: unquote(component),
          independent_children?: true,
          dependency_tree: %{}
        )

      {fn %unquote(mod).Input{} -> html end, %unquote(mod).Output{}}
    end
  end

  defn is_component?(it: %_{} = it, design: design) do
    it
    |> Type.type_of()
    |> cached_is_component?(design)
  end

  defn is_component?(it: _, design: _) do
    false
  end

  #
  # there is heavy cache
  #

  defmemop cached_is_component?(type, design), timeout: @heavy_cache_ttl do
    try do
      :ok = Protocol.assert_impl!(Componentable, type)
      %_{} = new_renderable(type, design)
      true
    rescue
      ArgumentError -> false
    end
  end

  defp new_renderable(comp_type, design) when is_atom(comp_type) do
    comp_type
    |> Bennu.Utils.comp_design_impl!(design)
    |> struct()
  end
end
