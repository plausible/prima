defmodule DemoWeb.ComboboxInitialSelectionTest do
  use Prima.WallabyCase, async: true

  @root "#submission-combobox"
  @input Query.css("#{@root} [data-prima-ref=search_input]")

  feature "initial selection uses the matching option label without firing phx-change", %{
    session: session
  } do
    session
    |> visit_selection(%{value: "a"})
    |> assert_combobox_selection(@root, "fruit", "Apple", "a")
    |> assert_has(Query.css("#submission-state[data-change-count='0']", visible: :any))
    |> assert_has(Query.css("#{@root} [data-value=a][data-selected=true]", visible: :any))
    |> click(@input)
    |> click(Query.css("#{@root} [data-value=b]"))
    |> assert_has(Query.css("#submission-state[data-change-count='1']", visible: :any))
    |> assert_combobox_selection(@root, "fruit", "Banana", "b")
  end

  feature "explicit display works for an initial value absent from the options", %{
    session: session
  } do
    session
    |> visit_selection(%{value: 42, display: "Saved"})
    |> assert_combobox_selection(@root, "fruit", "Saved", "42")
    |> click(@input)
    |> fill_in(@input, with: "query")
    |> send_keys([:escape])
    |> assert_combobox_selection(@root, "fruit", "Saved", "42")
    |> assert_has(Query.css("#submission-state[data-change-count='0']", visible: :any))
  end

  feature "multiple selection uses explicit, option, and fallback labels and remains removable",
          %{session: session} do
    session
    |> visit_selection([%{value: "a"}, %{value: "b", display: "Custom"}, %{value: 42}], true)
    |> assert_has(Query.css("#{@root} [data-prima-ref=selection-label]", count: 3))
    |> assert_has(Query.css("#{@root} [data-prima-ref=selection-label]", text: "Apple"))
    |> assert_has(Query.css("#{@root} [data-prima-ref=selection-label]", text: "Custom"))
    |> assert_has(Query.css("#{@root} [data-prima-ref=selection-label]", text: "42"))
    |> assert_multiple_values(["a", "b", "42"])
    |> assert_has(Query.css("#submission-state[data-change-count='0']", visible: :any))
    |> click(Query.css("#{@root} [data-prima-ref=remove-selection][data-value=b]"))
    |> assert_has(Query.css("#submission-state[data-change-count='1']", visible: :any))
    |> assert_has(Query.css("#{@root} [data-prima-ref=selection-label]", count: 2))
    |> assert_multiple_values(["a", "42"])
  end

  feature "empty string is an initial selection", %{session: session} do
    session
    |> visit_selection(%{value: ""})
    |> assert_combobox_selection(@root, "fruit", "Empty value", "")
    |> assert_has(Query.css("#submission-state[data-change-count='0']", visible: :any))
  end

  defp visit_selection(session, selection, multiple \\ false) do
    query = URI.encode_query(%{selection: Jason.encode!(selection), multiple: multiple})
    visit_fixture(session, "/fixtures/combobox-submission?#{query}", @root)
  end

  defp assert_multiple_values(session, values) do
    execute_script(
      session,
      """
      return {
        values: new FormData(document.querySelector('#submission-form')).getAll('fruits[]'),
        search: document.querySelector('#submission-combobox [data-prima-ref=search_input]').value
      };
      """,
      fn result -> assert result == %{"values" => values, "search" => ""} end
    )
  end
end
