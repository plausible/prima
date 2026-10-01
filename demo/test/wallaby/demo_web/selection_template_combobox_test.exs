defmodule DemoWeb.SelectionTemplateComboboxTest do
  use Prima.WallabyCase, async: true

  @search_input Query.css("#selection-template-combobox input[data-prima-ref=search_input]")
  @pill Query.css("#selection-template-combobox [data-prima-ref=selection-item]")
  @label Query.css("#selection-template-combobox [data-prima-ref=selection-label]")
  @remove Query.css("#selection-template-combobox .default-remove")
  @custom_remove Query.css("#selection-template-combobox .custom-remove")

  feature "pills show labels but remove and submit the original value", %{session: session} do
    session
    |> visit_fixture("/fixtures/selection-template-combobox", "#selection-template-combobox")
    |> click(@search_input)
    |> click(Query.css("#country-option"))
    |> assert_has(@label |> Query.text("United States"))
    |> assert_has(Query.css(".selection-pill .selection-icon", text: "★"))
    |> assert_has(Query.css(".selection-pill strong .selection-text", text: "United States"))
    |> assert_has(
      Query.css(".default-remove[data-value='US'][aria-label='Remove United States']")
    )
    |> assert_has(Query.css(".custom-remove[data-value='US'][aria-label='Remove selection']"))
    |> assert_submitted_values(["US"])
    |> click(@remove)
    |> assert_missing(@pill)
    |> assert_submitted_values([])
  end

  feature "HTML labels stay literal and values with quotes can be removed", %{session: session} do
    label = ~s(<b data-injected="true">__VALUE__ & "quoted"</b>)
    value = ~S(country["quoted"]\value)

    session
    |> visit_fixture("/fixtures/selection-template-combobox", "#selection-template-combobox")
    |> click(@search_input)
    |> click(Query.css("#quoted-option"))
    |> assert_has(@label |> Query.text(label))
    |> assert_literal_selection(value, label)
    |> assert_submitted_values([value])
    |> click(@custom_remove)
    |> assert_missing(@pill)
    |> assert_submitted_values([])
  end

  feature "created values containing HTML are displayed as text and remain removable", %{
    session: session
  } do
    value = ~s(<b data-injected="true">__VALUE__ & "created"</b>)

    session
    |> visit_fixture("/fixtures/selection-template-combobox", "#selection-template-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: value)
    |> assert_has(Query.css("[data-prima-ref=create-option][data-focus=true]"))
    |> send_keys([:enter])
    |> assert_has(@label |> Query.text(value))
    |> assert_literal_selection(value, value)
    |> assert_submitted_values([value])
    |> click(@remove)
    |> assert_missing(@pill)
    |> assert_submitted_values([])
  end

  defp assert_submitted_values(session, expected) do
    execute_script(
      session,
      "return new FormData(document.querySelector('#selection-template-form')).getAll('selections[]')",
      fn values -> assert values == expected end
    )
  end

  defp assert_literal_selection(session, value, label) do
    execute_script(
      session,
      """
      const item = document.querySelector('[data-prima-ref=selection-item]');
      const label = item.querySelector('[data-prima-ref=selection-label]');
      const button = item.querySelector('.default-remove');
      return {
        value: item.dataset.value,
        label: label.textContent,
        labelElementCount: label.childElementCount,
        buttonValue: button.dataset.value,
        buttonLabel: button.getAttribute('aria-label'),
        injectedElementCount: item.querySelectorAll('[data-injected]').length
      };
      """,
      fn result ->
        assert result == %{
                 "value" => value,
                 "label" => label,
                 "labelElementCount" => 0,
                 "buttonValue" => value,
                 "buttonLabel" => "Remove #{label}",
                 "injectedElementCount" => 0
               }
      end
    )
  end
end
