defmodule Bennu.Engine do
  use Defnamed, replace_kernel: true
  require Bennu.Component, as: Component
  require Bennu.Componentable.SchemaValue, as: SchemaValue
  require Bennu.Design.Meta, as: DesignMeta
  require Bennu.Env.OnDuplicate.Items, as: OnDuplicate
  require Bennu.Env.OnDuplicate.Meta, as: OnDuplicateMeta
  require Bennu.Env.Ref, as: EnvRef
  require Bennu.RenderContext, as: RenderContext

  defp validate_type!(
         key: key,
         value: value,
         schema_value:
           %SchemaValue{
             min_qty: min_qty,
             max_qty: max_qty,
             type: type
           } = schema_value
       )
       when is_list(value) and is_atom(type) do
    value
    |> length
    |> case do
      qty when is_nil(min_qty) or qty >= min_qty ->
        case is_nil(max_qty) or qty <= max_qty do
          true -> :ok
          false -> raise("#{key} qty=#{qty} for field of type #{inspect(schema_value)}")
        end

      qty ->
        raise("#{key} qty=#{qty} for field of type #{inspect(schema_value)}")
    end

    value
    |> Enum.each(fn val ->
      val
      |> Type.type_of()
      |> case do
        ^type -> :ok
        _ when type == Any -> :ok
        other -> raise("#{key} expected #{type} type, but got #{other} for #{inspect(value)}")
      end
    end)
  end

  defp create_input(
         component: %_{input: %_{} = raw_input},
         env: %{} = env,
         input_schema: %{} = input_schema
       ) do
    input_schema
    |> Enum.reduce(raw_input, fn {key, %SchemaValue{} = schema_value}, %_{} = input
                                 when is_atom(key) ->
      value =
        raw_input
        |> Map.fetch!(key)
        |> case do
          %EnvRef{key: env_key} ->
            #
            # TODO : in Env maybe use not just key, but type as well (how to deal with Any???)
            #
            Map.get(env, env_key) || []

          literal ->
            literal
        end

      :ok = validate_type!(key: key, value: value, schema_value: schema_value)
      Map.put(input, key, value)
    end)
  end

  defp update_env(
         env: %{} = env,
         output: %out{} = output,
         output_schema: %{} = output_schema,
         component: %_{output: %out{} = raw_output}
       ) do
    output_schema
    |> Enum.reduce(env, fn {key, %SchemaValue{} = schema_value}, %{} = env when is_atom(key) ->
      value = Map.fetch!(output, key)
      :ok = validate_type!(key: key, value: value, schema_value: schema_value)
      %EnvRef{key: env_key, on_duplicate: on_duplicate} = Map.fetch!(raw_output, key)
      true = OnDuplicateMeta.is_type(on_duplicate)

      Map.update(env, env_key, value, fn old ->
        case on_duplicate do
          OnDuplicate.raise() ->
            raise(
              "Env key #{env_key} is already presented with value #{inspect(old)}, but got new #{
                inspect(value)
              }"
            )

          OnDuplicate.ignore() ->
            old

          OnDuplicate.replace() ->
            value

          _ ->
            msvalue = MapSet.new(value)
            msold = MapSet.new(old)

            on_duplicate
            |> case do
              OnDuplicate.union() -> MapSet.union(msvalue, msold)
              OnDuplicate.intersection() -> MapSet.intersection(msvalue, msold)
            end
            |> MapSet.to_list()
        end
      end)
    end)
  end

  def render(
        context: %RenderContext{} = ctx,
        design: design,
        env: %{} = env,
        component: component,
        independent_children?: independent_children?
      )
      when DesignMeta.is_type(design) do
    input_schema = Component.input_schema(it: component)

    input =
      create_input(
        component: component,
        env: env,
        input_schema: input_schema
      )

    {renderer, output} =
      Component.render(
        context: ctx,
        component: component,
        design: design,
        input: input
      )

    new_env0 =
      update_env(
        env: env,
        output: output,
        output_schema: Component.output_schema(it: component),
        component: component
      )

    {children, new_env1} =
      render_children(
        context: ctx,
        design: design,
        env: new_env0,
        input: input,
        input_schema: input_schema,
        independent_children?: independent_children?
      )

    {renderer.(children), new_env1}
  end

  defp depends_on?(
         left: %_{input: %_{} = left_input} = left,
         right: %_{input: %_{} = right_input, output: %_{} = right_output} = right,
         design: design
       )
       when DesignMeta.is_type(design) do
    Component.is_component?(it: left, design: design)
    |> Kernel.and(Component.is_component?(it: right, design: design))
    |> case do
      true ->
        #
        # TODO : maybe validate types according input/output schema
        #

        # get direct right output Env keys
        right_output_mapset =
          right_output
          |> Map.from_struct()
          |> Map.values()
          |> Enum.reduce(MapSet.new(), fn %EnvRef{key: env_key}, acc ->
            MapSet.put(acc, env_key)
          end)

        left_input
        |> Map.from_struct()
        |> Map.values()
        |> Enum.any?(fn
          # direct left input depends on direct right output?
          %EnvRef{key: env_key} ->
            right_output_mapset
            |> MapSet.member?(env_key)

          # left childs are dependent on right?
          hardcoded when is_list(hardcoded) ->
            hardcoded
            |> Enum.any?(&depends_on?(left: &1, right: right, design: design))
        end)
        |> case do
          true ->
            true

          false ->
            # left depends on right childs?
            right_input
            |> Map.from_struct()
            |> Map.values()
            |> Stream.filter(fn
              %EnvRef{} -> false
              hardcoded when is_list(hardcoded) -> true
            end)
            |> Enum.any?(fn hardcoded ->
              hardcoded
              |> Enum.any?(&depends_on?(left: left, right: &1, design: design))
            end)
        end

      false ->
        false
    end
  end

  defp depends_on?(left: _, right: _, design: _) do
    false
  end

  defp can_render?(
         it: it,
         parent_input: %_{} = parent_input,
         design: design,
         independent_children?: independent_children?
       )
       when DesignMeta.is_type(design) do
    Component.is_component?(
      it: it,
      design: design
    )
    |> case do
      true when independent_children? == true ->
        true

      true ->
        parent_input
        |> Map.from_struct()
        |> Map.values()
        |> Enum.all?(fn
          %EnvRef{} ->
            true

          hardcoded when is_list(hardcoded) ->
            hardcoded
            |> Enum.all?(&(not depends_on?(left: it, right: &1, design: design)))
        end)

      false ->
        false
    end
  end

  defp assert_rendered!(rendered_input: %_{} = input, design: design) do
    input
    |> Map.from_struct()
    |> Map.values()
    |> Enum.each(fn htmls when is_list(htmls) ->
      htmls
      |> Enum.each(fn it ->
        if Component.is_component?(it: it, design: design) do
          raise(
            "component #{inspect(it)} wasn't rendered with design #{design} (probably because of dependency on other component)"
          )
        end
      end)
    end)
  end

  Kernel.defp render_children(
                context: %RenderContext{} = ctx,
                design: design,
                env: %{} = env,
                input: %_{} = input,
                input_schema: %{} = input_schema,
                independent_children?: independent_children?
              )
              when DesignMeta.is_type(design) do
    input_schema
    |> Enum.reduce({input, env}, fn {key, %SchemaValue{}}, {%_{} = acc, %{} = env}
                                    when is_atom(key) ->
      {new_comps, %{} = new_env} =
        acc
        |> Map.fetch!(key)
        |> Stream.with_index()
        |> Enum.reverse()
        |> Enum.reduce({[], env}, fn {x, index}, {acc, %{} = env} when is_list(acc) ->
          can_render?(
            it: x,
            parent_input: input,
            design: design,
            independent_children?: independent_children?
          )
          |> case do
            true ->
              new_ctx = %RenderContext{
                ctx
                | parent: ctx,
                  component: x,
                  name: key,
                  index: index
              }

              {html, %{} = new_env} =
                render(
                  context: new_ctx,
                  design: design,
                  env: env,
                  component: x,
                  independent_children?: independent_children?
                )

              {[html | acc], new_env}

            false ->
              {[x | acc], env}
          end
        end)

      {Map.put(acc, key, new_comps), new_env}
    end)
    |> case do
      {^input, %{} = new_env} ->
        :ok = assert_rendered!(rendered_input: input, design: design)
        {input, new_env}

      {%_{} = new_input, %{} = new_env} when independent_children? == true ->
        {new_input, new_env}

      {%_{} = new_input, %{} = new_env} ->
        render_children(
          context: ctx,
          design: design,
          env: new_env,
          input: new_input,
          input_schema: input_schema,
          independent_children?: independent_children?
        )
    end
  end
end
