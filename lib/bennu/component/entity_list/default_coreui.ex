use Bennu.Component.EntityList

defrender type: EntityList,
          design: Design.default_coreui(),
          input: %Input{
            title: [title],
            header: input_header,
            rows: input_rows
          },
          context: %RenderContext{conn: %Conn{} = conn} = ctx do
  #
  # TODO : use LiveView to make it sortable/searchable?
  #

  header = %ComponentList{
    input: %ComponentList.Input{items: Enum.concat(input_header, [""])}
  }

  rows =
    input_rows
    |> Enum.map(fn xs ->
      open_btn = %Button{
        input: %Button.Input{
          onclick: [],
          form_name: [],
          href: [Utils.push_path(conn, List.first(xs))],
          text: ["Open"],
          icon: [FaIcon.eye()],
          bs_color: [BSColor.primary()]
        }
      }

      %ComponentList{
        input: %ComponentList.Input{items: Enum.concat(xs, [open_btn])}
      }
    end)

  table = %Table{
    input: %Table.Input{
      header: [header],
      rows: rows
    }
  }

  component = %Card{
    input: %Card.Input{
      header: [
        %ComponentList{
          input: %ComponentList.Input{
            items: [
              title,
              %Button{
                input: %Button.Input{
                  form_name: [],
                  onclick: [],
                  #
                  # TODO : think how it could be done better
                  #
                  href: [Utils.push_path(conn, "new")],
                  text: ["Add"],
                  icon: [FaIcon.plus()],
                  bs_color: [BSColor.primary()]
                }
              }
            ]
          }
        }
      ],
      body: [table],
      footer: []
    }
  }

  trivial_renderer(
    for: EntityList,
    context: ctx,
    design: Design.default_coreui(),
    component: component
  )
end
