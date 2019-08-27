use Bennu.Component.DBEntityDetails

defrender type: DBEntityDetails,
          design: Design.default_coreui(),
          input: %Input{
            parent_path: [parent_path],
            update_form_name: [update_form_name],
            delete_form_name: [delete_form_name],
            title: [title],
            live: [live],
            compact: [compact]
          },
          context: %RenderContext{socket: %Socket{} = socket} = ctx do
  component = %Card{
    input: %Card.Input{
      header: [
        %ComponentList{
          input: %ComponentList.Input{items: [title]},
          output: %ComponentList.Output{}
        }
      ],
      body: [live],
      footer: [
        %ComponentList{
          input: %ComponentList.Input{
            items: [
              %Button{
                input: %Button.Input{
                  onclick: [],
                  form_name: [update_form_name],
                  src: [],
                  text: ["Update"],
                  icon: [FaIcon.save()],
                  bs_color: [BSColor.primary()]
                },
                output: %Button.Output{}
              },
              %Button{
                input: %Button.Input{
                  onclick: [],
                  form_name: [delete_form_name],
                  src: [],
                  text: ["Delete"],
                  icon: [FaIcon.ban()],
                  bs_color: [BSColor.danger()]
                },
                output: %Button.Output{}
              },
              %Button{
                input: %Button.Input{
                  onclick: [],
                  form_name: [],
                  src: [parent_path],
                  text: ["Cancel"],
                  icon: [FaIcon.ban()],
                  bs_color: [BSColor.dark()]
                },
                output: %Button.Output{}
              }
            ]
          },
          output: %ComponentList.Output{}
        }
      ]
    },
    output: %Card.Output{}
  }

  {html, %{}} =
    Engine.render(
      context: ctx,
      design: Design.default_coreui(),
      env: %{},
      component: component,
      independent_children?: true
    )

  renderer = fn %Input{} ->
    assigns = %{html: html, socket: socket}

    case compact do
      true ->
        ~l"""
        .container.compact
          = @html
        """

      false ->
        ~l"""
        .container
          = @html
        """
    end
  end

  {renderer, %Output{}}
end
