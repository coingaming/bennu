defmodule Bennu.Engine do
  use Defnamed, replace_kernel: true
  require Bennu.Component, as: Component
  require Bennu.Componentable.SchemaValue, as: SchemaValue
  require Bennu.Env.OnDuplicate.Items, as: OnDuplicate
  require Bennu.Env.OnDuplicate.Meta, as: OnDuplicateMeta
  require Bennu.Env.Ref, as: EnvRef
  require Bennu.RenderContext, as: RenderContext

  # defp validate_type!(
  #        key: key,
  #        value: value,
  #        schema_value:
  #          %SchemaValue{
  #            min_qty: min_qty,
  #            max_qty: max_qty,
  #            type: %_{} = type
  #          } = schema_value
  #      )
  #      when is_list(value) do
  #   value
  #   |> length
  #   |> case do
  #     qty when is_nil(min_qty) or qty >= min_qty ->
  #       case is_nil(max_qty) or qty <= max_qty do
  #         true -> :ok
  #         false -> raise("#{key} qty=#{qty} for field of type #{inspect(schema_value)}")
  #       end

  #     qty ->
  #       raise("#{key} qty=#{qty} for field of type #{inspect(schema_value)}")
  #   end

  #   value
  #   |> Enum.each(fn val ->
  #     val
  #     |> Type.type_of()
  #     |> case do
  #       ^type -> :ok
  #       _ when type == Any -> :ok
  #       other -> raise("#{key} expected #{type} type, but got #{other} for #{inspect(value)}")
  #     end
  #   end)
  # end

  defp create_input(
         component: %_{input: %_{} = raw_input},
         env: %{} = env,
         input_schema: %{} = input_schema
       ) do
    input_schema
    |> Enum.reduce(raw_input, fn {key, %SchemaValue{}}, %_{} = input
                                 when is_atom(key) ->
      value =
        raw_input
        |> Map.fetch!(key)
        |> Enum.flat_map(fn
          %EnvRef{key: env_key} ->
            #
            # TODO : in Env maybe use not just key, but type as well (how to deal with Any???)
            #
            case Map.get(env, env_key) do
              nil -> []
              x when is_list(x) -> x
              x -> [x]
            end

          literal ->
            [literal]
        end)

      # :ok = validate_type!(key: key, value: value, schema_value: schema_value)
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
    |> Enum.reduce(env, fn {key, %SchemaValue{}}, %{} = env when is_atom(key) ->
      value = Map.fetch!(output, key)
      # :ok = validate_type!(key: key, value: value, schema_value: schema_value)
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
        context: ctx,
        design: design,
        env: %{} = env,
        component: component,
        independent_children?: independent_children?,
        dependency_tree: %{} = dependency_tree
      ) do
    input_schema = Component.input_schema(it: component)

    input =
      create_input(
        component: component,
        env: env,
        input_schema: input_schema
      )

    # Continue to support single `output` return instead of `{output, assigns}` tuple
    {output_from_evaluate, assigns_from_evaluate} =
      case Component.evaluate(
             context: ctx,
             component: component,
             design: design,
             input: input
           ) do
        {_output, assigns} = value when is_map(assigns) -> value
        {output, _} -> {output, %{}}
        output -> {output, %{}}
      end

    new_env0 =
      update_env(
        env: env,
        output: output_from_evaluate,
        output_schema: Component.output_schema(it: component),
        component: component
      )

    {evaluated_input, new_env1, dependency_tree} =
      evaluate_children(
        context: ctx,
        design: design,
        env: new_env0,
        input: input,
        input_schema: input_schema,
        independent_children?: independent_children?,
        dependency_tree: dependency_tree
      )

    assigns =
      evaluated_input
      |> Map.from_struct()
      |> Map.merge(assigns_from_evaluate)
      |> Map.to_list()

    live_component =
      [
        Bennu.Renderable,
        component
        |> Typable.type_of()
        |> Bennu.Utils.comp_design_impl!(design)
      ]
      |> Module.safe_concat()

    {Component.component(module: live_component, assigns: assigns), new_env1, dependency_tree}
  end

  defp depends_on?(
         left: %_{input: %_{} = left_input} = left,
         right: %_{input: %_{} = right_input, output: %_{} = right_output} = right,
         design: design,
         dependency_tree: %{} = dependency_tree
       ) do
    dependency_tree
    |> get_in([left, right])
    |> case do
      true ->
        {true, dependency_tree}

      false ->
        {false, dependency_tree}

      nil ->
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
            |> Enum.reduce_while({false, dependency_tree}, fn
              # left childs are dependent on right?
              hardcoded, {false, dependency_tree} when is_list(hardcoded) ->
                hardcoded
                |> Enum.reduce_while({false, dependency_tree}, fn
                  # direct left input depends on direct right output?
                  %EnvRef{key: env_key}, {false, dependency_tree} ->
                    right_output_mapset
                    |> MapSet.member?(env_key)
                    |> case do
                      true -> {:halt, {true, dependency_tree}}
                      false -> {:cont, {false, dependency_tree}}
                    end

                  left, {false, dependency_tree} ->
                    depends_on?(
                      left: left,
                      right: right,
                      design: design,
                      dependency_tree: dependency_tree
                    )
                    |> case do
                      res = {true, %{}} -> {:halt, res}
                      res = {false, %{}} -> {:cont, res}
                    end
                end)
                |> case do
                  res = {true, %{}} -> {:halt, res}
                  res = {false, %{}} -> {:cont, res}
                end
            end)
            |> case do
              res = {true, %{}} ->
                res

              {false, dependency_tree} ->
                # left depends on right childs?
                right_input
                |> Map.from_struct()
                |> Map.values()
                |> Enum.reduce_while(
                  {false, dependency_tree},
                  fn
                    %EnvRef{}, res ->
                      {:cont, res}

                    right, {false, dependency_tree} ->
                      depends_on?(
                        left: left,
                        right: right,
                        design: design,
                        dependency_tree: dependency_tree
                      )
                      |> case do
                        res = {true, %{}} -> {:halt, res}
                        res = {false, %{}} -> {:cont, res}
                      end
                  end
                )
            end

          false ->
            {false, dependency_tree}
        end
    end
    |> add_dependency(left, right)
  end

  defp depends_on?(left: left, right: right, design: _, dependency_tree: dependency_tree = %{}) do
    {false, dependency_tree}
    |> add_dependency(left, right)
  end

  defp can_render?(
         it: it,
         parent_input: %_{} = parent_input,
         design: design,
         independent_children?: independent_children?,
         dependency_tree: %{} = dependency_tree
       ) do
    Component.is_component?(
      it: it,
      design: design
    )
    |> case do
      true when independent_children? == true ->
        {true, dependency_tree}

      true ->
        parent_input
        |> Map.from_struct()
        |> Map.values()
        |> Enum.reduce_while({true, dependency_tree}, fn
          hardcoded, {true, dependency_tree} when is_list(hardcoded) ->
            hardcoded
            |> Enum.reduce_while({false, dependency_tree}, fn
              %EnvRef{}, res ->
                {:cont, res}

              right, {_, dependency_tree} ->
                depends_on?(
                  left: it,
                  right: right,
                  design: design,
                  dependency_tree: dependency_tree
                )
                |> case do
                  res = {true, %{}} -> {:halt, res}
                  res = {false, %{}} -> {:cont, res}
                end
            end)
            |> case do
              {true, dependency_tree} -> {:halt, {false, dependency_tree}}
              {false, dependency_tree} -> {:cont, {true, dependency_tree}}
            end
        end)

      false ->
        {false, dependency_tree}
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

  Kernel.defp evaluate_children(
                context: %RenderContext{} = ctx,
                design: design,
                env: %{} = env,
                input: %_{} = input,
                input_schema: %{} = input_schema,
                independent_children?: independent_children?,
                dependency_tree: %{} = dependency_tree
              ) do
    input_schema
    |> Enum.reduce({input, env, dependency_tree}, fn {key, %SchemaValue{}},
                                                     {
                                                       %_{} = acc,
                                                       %{} = env,
                                                       %{} = dependency_tree
                                                     }
                                                     when is_atom(key) ->
      {new_comps, %{} = new_env, %{} = dependency_tree} =
        acc
        |> Map.fetch!(key)
        |> Stream.with_index()
        |> Enum.reverse()
        |> Enum.reduce({[], env, dependency_tree}, fn {x, index},
                                                      {
                                                        acc,
                                                        %{} = env,
                                                        %{} = dependency_tree
                                                      }
                                                      when is_list(acc) ->
          can_render?(
            it: x,
            parent_input: input,
            design: design,
            independent_children?: independent_children?,
            dependency_tree: dependency_tree
          )
          |> case do
            {true, dependency_tree} ->
              new_ctx = %RenderContext{
                ctx
                | parent: ctx,
                  component: x,
                  name: key,
                  index: index
              }

              {html, %{} = new_env, %{} = dependency_tree} =
                render(
                  context: new_ctx,
                  design: design,
                  env: env,
                  component: x,
                  independent_children?: independent_children?,
                  dependency_tree: dependency_tree
                )

              {[html | acc], new_env, dependency_tree}

            {false, dependency_tree} ->
              {[x | acc], env, dependency_tree}
          end
        end)

      {Map.put(acc, key, new_comps), new_env, dependency_tree}
    end)
    |> case do
      {^input, %{} = new_env, dependency_tree} ->
        :ok = assert_rendered!(rendered_input: input, design: design)
        {input, new_env, dependency_tree}

      {%_{} = new_input, %{} = new_env, dependency_tree} when independent_children? == true ->
        {new_input, new_env, dependency_tree}

      {%_{} = new_input, %{} = new_env, dependency_tree} ->
        evaluate_children(
          context: ctx,
          design: design,
          env: new_env,
          input: new_input,
          input_schema: input_schema,
          independent_children?: independent_children?,
          dependency_tree: dependency_tree
        )
    end
  end

  Kernel.defp add_dependency({is, %{} = dependency_tree}, left, right) when is_boolean(is) do
    {is, Map.update(dependency_tree, left, %{right => is}, &Map.put(&1, right, is))}
  end
end
