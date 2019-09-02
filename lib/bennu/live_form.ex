defmodule Bennu.LiveForm do
  require Bennu.Design.Meta, as: DesignMeta

  defmacro __using__(web_module) do
    quote location: :keep do
      use Phoenix.LiveView
      use PhoenixComponents.View, namespace: unquote(web_module).Components

      import_components(
        [
          :alert,
          :detail_wrapper,
          :form_footer,
          :form_wrapper,
          :list_option,
          :list_wrapper,
          :input_group,
          :tag_label,
          :enum_select
        ],
        from: BackofficeCoreWeb.Components
      )

      defp enum_gettext(enum_name, item) when is_atom(enum_name) and is_atom(item) do
        enum_gettext(enum_name |> Atom.to_string(), item |> Atom.to_string())
      end

      defp enum_gettext(enum_name, item) do
        Gettext.dgettext(unquote(web_module).Gettext, enum_name, item)
      end

      defp has_errors?(%{errors: errors}, field) do
        not Enum.empty?(Keyword.get_values(errors, field))
      end

      defp input_class(form, field) do
        "form-control" <> ((has_errors?(form, field) && " is-invalid") || "")
      end

      import Phoenix.HTML.Form
      import unquote(web_module).ErrorHelpers
    end
  end

  defmacro elixir_term_textarea(form, field, opts0 \\ []) do
    quote location: :keep, bind_quoted: [form: form, field: field, opts0: opts0] do
      opts1 =
        opts0
        |> Keyword.put_new(:id, input_id(form, field))
        |> Keyword.put_new(:name, input_name(form, field))

      {value, opts} = Keyword.pop(opts1, :value, input_value(form, field) || "[]")

      new_value =
        value
        |> Bennu.Ecto.ElixirTerm.dump()
        |> case do
          {:ok, x} -> x
          :error -> value
        end

      Phoenix.HTML.Tag.content_tag(:textarea, ["\n", Phoenix.HTML.html_escape(new_value)], opts)
    end
  end

  defmacro defrender_form_new(
             type: quoted_type,
             design: quoted_design,
             compact: compact,
             model_name: model_name
           )
           when is_boolean(compact) and is_binary(model_name) do
    {type, []} = Code.eval_quoted(quoted_type, [], __CALLER__)
    {design, []} = Code.eval_quoted(quoted_design, [], __CALLER__)
    true = DesignMeta.is_type(design)
    title = "New #{model_name}"
    live_module = Module.concat(type, Bennu.Utils.enum2module(design) <> "Live")

    quote location: :keep do
      defrender type: unquote(type),
                design: unquote(design),
                input: %unquote(type).Input{},
                context: %Bennu.RenderContext{conn: %Plug.Conn{} = conn} = ctx do
        parent_path = Bennu.Utils.pop_path(conn)
        form_name = inspect(__MODULE__)

        live = %Bennu.Component.Live{
          input: %Bennu.Component.Live.Input{
            module: [unquote(live_module)],
            session: [
              %unquote(live_module){
                form_name: form_name,
                parent_path: parent_path,
                changeset: nil,
                state: nil
              }
            ]
          },
          output: %Bennu.Component.Live.Output{}
        }

        component = %Bennu.Component.DBEntityNew{
          input: %Bennu.Component.DBEntityNew.Input{
            parent_path: [parent_path],
            form_name: [form_name],
            title: [unquote(title)],
            live: [live],
            compact: [unquote(compact)]
          },
          output: %Bennu.Component.DBEntityNew.Output{}
        }

        trivial_renderer(
          for: unquote(type),
          context: ctx,
          design: unquote(design),
          component: component
        )
      end
    end
  end

  defmacro defrender_form_details(
             type: quoted_type,
             design: quoted_design,
             compact: compact,
             model_key: model_key,
             model_type: quoted_model_type,
             model_name: model_name,
             state_constructor: state_constructor
           )
           when is_boolean(compact) and is_atom(model_key) and is_binary(model_name) do
    {type, []} = Code.eval_quoted(quoted_type, [], __CALLER__)
    {design, []} = Code.eval_quoted(quoted_design, [], __CALLER__)
    {model_type, []} = Code.eval_quoted(quoted_model_type, [], __CALLER__)
    true = DesignMeta.is_type(design)
    title = "#{model_name} Details"
    live_module = Module.concat(type, Bennu.Utils.enum2module(design) <> "Live")

    model = {:model, [], Elixir}

    model_pattern =
      {:=, [],
       [
         {:%, [],
          [
            {:__aliases__, [alias: false],
             model_type |> Module.split() |> Enum.map(&String.to_atom/1)},
            {:%{}, [], []}
          ]},
         model
       ]}

    input_ast =
      {:%, [],
       [
         {:__aliases__, [alias: false],
          Module.split(type) |> Enum.map(&String.to_atom/1) |> Enum.concat([:Input])},
         {:%{}, [], [{model_key, [model_pattern]}]}
       ]}

    quote location: :keep do
      defrender type: unquote(type),
                design: unquote(design),
                input: unquote(input_ast),
                context: %Bennu.RenderContext{conn: %Plug.Conn{} = conn} = ctx do
        update_form_name = "update_#{inspect(__MODULE__)}"
        delete_form_name = "delete_#{inspect(__MODULE__)}"
        parent_path = Bennu.Utils.pop_path(conn)

        live = %Bennu.Component.Live{
          input: %Bennu.Component.Live.Input{
            module: [unquote(live_module)],
            session: [
              %unquote(live_module){
                model: unquote(model),
                update_form_name: update_form_name,
                delete_form_name: delete_form_name,
                parent_path: parent_path,
                changeset: nil,
                state: unquote(state_constructor).(unquote(model))
              }
            ]
          },
          output: %Bennu.Component.Live.Output{}
        }

        component = %Bennu.Component.DBEntityDetails{
          input: %Bennu.Component.DBEntityDetails.Input{
            parent_path: [parent_path],
            update_form_name: [update_form_name],
            delete_form_name: [delete_form_name],
            title: [unquote(title)],
            live: [live],
            compact: [unquote(compact)]
          },
          output: %Bennu.Component.DBEntityDetails.Output{}
        }

        trivial_renderer(
          for: unquote(type),
          context: ctx,
          design: unquote(design),
          component: component
        )
      end
    end
  end

  defmacro defphx_mount_new(type: type, default_params: default_params) do
    quote location: :keep do
      def mount(%__MODULE__{} = session, socket) do
        state = %__MODULE__{
          session
          | changeset: unquote(type).changeset(%unquote(type){}, unquote(default_params))
        }

        {:ok, assign(socket, state: state)}
      end
    end
  end

  defmacro defphx_change_new(type: type, string_key: string_key) do
    quote location: :keep do
      def handle_event(
            "phx_change",
            %{unquote(string_key) => params},
            %Phoenix.LiveView.Socket{assigns: %{state: %__MODULE__{} = state}} = socket
          ) do
        cs =
          %unquote(type){}
          |> unquote(type).changeset(params)
          |> Map.put(:action, :insert)

        {:noreply, assign(socket, state: %__MODULE__{state | changeset: cs})}
      end
    end
  end

  defmacro defphx_submit_new(type: type, string_key: string_key, name: name) do
    msg = "#{name} created successfully"

    quote location: :keep do
      def handle_event(
            "phx_submit",
            %{unquote(string_key) => params},
            %Phoenix.LiveView.Socket{
              assigns: %{
                state:
                  %__MODULE__{
                    parent_path: parent_path
                  } = state
              }
            } = socket
          ) do
        params
        |> unquote(type).create()
        |> case do
          {:ok, %unquote(type){}} ->
            {
              :stop,
              socket
              |> put_flash(:info, unquote(msg))
              |> redirect(to: parent_path)
            }

          {:error, %Ecto.Changeset{} = cs} ->
            {
              :noreply,
              assign(socket, state: %__MODULE__{state | changeset: cs})
            }
        end
      end
    end
  end

  defmacro defphx_mount_details(type: type) do
    quote location: :keep do
      def mount(%__MODULE__{model: %unquote(type){} = model} = session, socket) do
        state = %__MODULE__{session | changeset: unquote(type).change(model)}
        {:ok, assign(socket, state: state)}
      end
    end
  end

  defmacro defphx_delete_details(type: type, name: name) do
    msg = "#{name} deleted successfully"

    quote location: :keep do
      def handle_event(
            "phx_delete",
            %{},
            %Phoenix.LiveView.Socket{
              assigns: %{
                state:
                  %__MODULE__{
                    model: %unquote(type){} = model,
                    parent_path: parent_path
                  } = state
              }
            } = socket
          ) do
        model
        |> unquote(type).delete()
        |> case do
          {:ok, %unquote(type){}} ->
            {
              :stop,
              socket
              |> put_flash(:warn, unquote(msg))
              |> redirect(to: parent_path)
            }

          {:error, %Ecto.Changeset{} = cs} ->
            {
              :noreply,
              assign(socket, state: %__MODULE__{state | changeset: cs})
            }
        end
      end
    end
  end

  defmacro defphx_change_details(type: type, string_key: string_key) do
    quote location: :keep do
      def handle_event(
            "phx_change",
            %{unquote(string_key) => params},
            %Phoenix.LiveView.Socket{
              assigns: %{state: %__MODULE__{model: %unquote(type){} = model} = state}
            } = socket
          ) do
        cs =
          model
          |> unquote(type).changeset(params)
          |> Map.put(:action, :update)

        {:noreply, assign(socket, state: %__MODULE__{state | changeset: cs})}
      end
    end
  end

  defmacro defphx_submit_details(type: type, string_key: string_key, name: name) do
    msg = "#{name} updated successfully"

    quote location: :keep do
      def handle_event(
            "phx_submit",
            %{unquote(string_key) => params},
            %Phoenix.LiveView.Socket{
              assigns: %{
                state:
                  %__MODULE__{
                    model: %unquote(type){} = model,
                    parent_path: parent_path
                  } = state
              }
            } = socket
          ) do
        model
        |> unquote(type).update(params)
        |> case do
          {:ok, %unquote(type){}} ->
            {
              :stop,
              socket
              |> put_flash(:info, unquote(msg))
              |> redirect(to: parent_path)
            }

          {:error, %Ecto.Changeset{} = cs} ->
            {
              :noreply,
              assign(socket, state: %__MODULE__{state | changeset: cs})
            }
        end
      end
    end
  end
end
