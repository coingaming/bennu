use Bennu.Component.DBEntityList

defrender type: DBEntityList,
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
    input: %ComponentList.Input{items: Enum.concat(input_header, [""])},
    output: %ComponentList.Output{}
  }

  rows =
    input_rows
    |> Enum.map(fn xs ->
      open_btn = %Button{
        input: %Button.Input{
          onclick: [],
          form_name: [],
          src: [Utils.push_path(conn, List.first(xs))],
          text: ["Open"],
          icon: [FaIcon.eye()],
          bs_color: [BSColor.primary()]
        },
        output: %Button.Output{}
      }

      %ComponentList{
        input: %ComponentList.Input{items: Enum.concat(xs, [open_btn])},
        output: %ComponentList.Output{}
      }
    end)

  table = %Table{
    input: %Table.Input{
      header: [header],
      rows: rows
    },
    output: %Table.Output{}
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
                  src: [Utils.push_path(conn, "new")],
                  text: ["Add"],
                  icon: [FaIcon.plus()],
                  bs_color: [BSColor.primary()]
                },
                output: %Button.Output{}
              }
            ]
          },
          output: %ComponentList.Output{}
        }
      ],
      body: [table],
      footer: []
    },
    output: %Card.Output{}
  }

  trivial_renderer(
    for: DBEntityList,
    context: ctx,
    design: Design.default_coreui(),
    component: component
  )
end
