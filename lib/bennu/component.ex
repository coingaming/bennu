defmodule Bennu.Component do
  @moduledoc """
  Provides utilities to implement and work with
  `Bennu.Componentable` and
  `Bennu.Renderable` types
  """

  require Bennu.Componentable, as: Componentable
  require Bennu.Renderable, as: Renderable
  require Bennu.Design.Meta, as: Design
  require Bennu.RenderContext, as: RenderContext
  require Bennu.Componentable.SchemaValue, as: SchemaValue
  use Defnamed
  import Meme

  @heavy_cache_ttl nil

  # abstract Component data type
  # in reality it's one of %Grid{} | %Column{} | etc
  @type t :: term()

  defmacro __using__(_) do
    quote do
      require Bennu.Bootstrap.Color.Items, as: BSColor
      require Bennu.Bootstrap.Color.Meta, as: BSColorMeta
      require Bennu.Coreui.Icon.Items, as: CoreuiIcon
      require Bennu.Coreui.Icon.Meta, as: CoreuiIconMeta
      require Bennu.Design.Items, as: Design
      require Bennu.Design.Meta, as: DesignMeta
      require Bennu.Engine, as: Engine
      require Bennu.Env.OnDuplicate.Items, as: OnDuplicate
      require Bennu.Env.Ref, as: EnvRef
      require Bennu.FontAwesome.Icon.Items, as: FaIcon
      require Bennu.RenderContext, as: RenderContext
      require Bennu.Utils, as: Utils
      require Ecto.Changeset, as: Changeset
      require Phoenix.LiveView.Socket, as: Socket
      require unquote(__MODULE__), as: Component
      import Bennu.LiveForm
      import Bennu.Sigil
      import PhoenixSlime
      import unquote(__MODULE__), only: [defcomponent: 2, defrender: 2, trivial_renderer: 1]
      alias Component.BOIndex
      alias Component.Brand
      alias Component.Breadcrumb
      alias Component.Button
      alias Component.Card
      alias Component.Column
      alias Component.ComponentList
      alias Component.DBEntityDetails
      alias Component.DBEntityList
      alias Component.DBEntityNew
      alias Component.Flash
      alias Component.Game
      alias Component.Grid
      alias Component.Live
      alias Component.Markdown
      alias Component.NavLink
      alias Component.Page
      alias Component.PageHeader
      alias Component.PageSidebar
      alias Component.Table
    end
  end

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
        |> Enum.reduce(%{}, fn {field, _, [spec]}, %{} = acc ->
          false = Map.has_key?(acc, field)
          Map.put_new(acc, field, spec)
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

    quote location: :keep do
      defmodule unquote(type) do
        @type t :: %__MODULE__{
                input: unquote(input_type).t(),
                output: unquote(output_type).t()
              }
        @enforce_keys [:input, :output]
        defstruct @enforce_keys

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

      defmodule unquote(input_type) do
        #
        # TODO : GENERATE TYPE T PROPERLY???
        #
        @type t :: %__MODULE__{}
        @enforce_keys unquote(Map.keys(input_spec))
        defstruct @enforce_keys
      end

      defmodule unquote(output_type) do
        #
        # TODO : GENERATE TYPE T PROPERLY???
        #
        @type t :: %__MODULE__{}
        @enforce_keys unquote(Map.keys(output_spec))
        defstruct @enforce_keys
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

  defmacro defrender(
             [
               type: quoted_type,
               design: quoted_design,
               input: quoted_input,
               context: quoted_context
             ],
             do: code
           ) do
    {short_type, []} = Code.eval_quoted(quoted_type, [], __CALLER__)
    {design, []} = Code.eval_quoted(quoted_design, [], __CALLER__)
    #
    # TODO : try-catch with more detailed reraise
    #
    :ok = Type.assert_exist!(short_type)
    :ok = Protocol.assert_impl!(Componentable, short_type)
    true = Design.is_type(design)

    type =
      [
        Bennu,
        Renderable,
        short_type,
        WithDesign,
        design |> Atom.to_string() |> String.downcase() |> Macro.camelize()
      ]
      |> Module.concat()

    quote do
      defmodule unquote(type) do
        @enforce_keys []
        defstruct @enforce_keys
      end

      defimpl Bennu.Renderable, for: unquote(type) do
        def render(%unquote(type){}, unquote(quoted_input), unquote(quoted_context)) do
          unquote(code)
        end
      end
    end
  end

  defn input_schema(it: it) do
    Componentable.input_schema(it)
  end

  defn output_schema(it: it) do
    Componentable.output_schema(it)
  end

  defn render(context: %RenderContext{} = ctx, component: component, design: design, input: input)
       when Design.is_type(design) do
    component
    |> Type.type_of()
    |> new_renderable(design)
    |> Renderable.render(input, ctx)
  end

  defmacron trivial_renderer(for: mod, context: ctx, design: design, component: component) do
    quote location: :keep do
      {html, %{}} =
        Bennu.Engine.render(
          context: unquote(ctx),
          design: unquote(design),
          env: %{},
          component: unquote(component),
          independent_children?: true
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

  defp new_renderable(short_type, design) when is_atom(short_type) and Design.is_type(design) do
    #
    # TODO : try-catch with more detailed reraise
    #
    type =
      [
        Bennu,
        Renderable,
        short_type,
        WithDesign,
        design |> Atom.to_string() |> String.downcase() |> Macro.camelize()
      ]
      |> Module.safe_concat()

    type.__struct__()
  end
end
