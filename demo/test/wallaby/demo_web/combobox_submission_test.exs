defmodule DemoWeb.ComboboxSubmissionTest do
  use Prima.WallabyCase, async: true

  @input Query.css("#submission-combobox [data-prima-ref=search_input]")

  feature "single selection changes are complete before events fire", %{session: session} do
    session
    |> visit_submission(false)
    |> select_value("a")
    |> assert_change(1, "fruit", %{"fruit" => "a"}, [["fruit", "a"]])
    |> select_value("b")
    |> assert_change(2, "fruit", %{"fruit" => "b"}, [["fruit", "b"]])
    |> clear_selection()
    |> assert_change(3, "fruit", %{}, [])
    |> select_value("")
    |> assert_change(4, "fruit", %{"fruit" => ""}, [["fruit", ""]])
    |> clear_selection()
    |> assert_change(5, "fruit", %{}, [])
  end

  feature "removing one of multiple selections never emits a phantom empty value", %{
    session: session
  } do
    session
    |> visit_submission(true)
    |> select_value("a")
    |> assert_change(1, "fruits", %{"fruits" => ["a"]}, [["fruits[]", "a"]])
    |> select_value("b")
    |> assert_change(2, "fruits", %{"fruits" => ["a", "b"]}, [
      ["fruits[]", "a"],
      ["fruits[]", "b"]
    ])
    |> click(Query.css("[data-prima-ref=remove-selection][data-value=a]"))
    |> assert_change(3, "fruits", %{"fruits" => ["b"]}, [["fruits[]", "b"]])
    |> select_value("")
    |> assert_change(4, "fruits", %{"fruits" => ["b", ""]}, [
      ["fruits[]", "b"],
      ["fruits[]", ""]
    ])
    |> click(Query.css("[data-prima-ref=remove-selection][data-value=b]"))
    |> assert_change(5, "fruits", %{"fruits" => [""]}, [["fruits[]", ""]])
    |> clear_selection()
    |> assert_change(6, "fruits", %{}, [])
  end

  defp visit_submission(session, multiple) do
    session
    |> visit_fixture("/fixtures/combobox-submission?multiple=#{multiple}", "#submission-combobox")
    |> execute_script("""
    const form = document.querySelector('#submission-form');
    window.submissionControl = form.querySelector('[data-prima-ref=submit_input]');
    window.selectionEvents = [];
    for (const type of ['input', 'change']) {
      form.addEventListener(type, event => {
        window.selectionEvents.push({
          type,
          sameControl: event.target === window.submissionControl,
          entries: Array.from(new FormData(form).entries())
        });
      });
    }
    """)
  end

  defp select_value(session, value) do
    session
    |> click(@input)
    |> click(Query.css("#submission-options [role=option][data-value='#{value}']"))
  end

  defp clear_selection(session) do
    session
    |> click(@input)
    |> assert_has(Query.css("#submission-options", visible: true))
    |> send_keys([:backspace])
    |> send_keys([:escape])
    |> assert_has(Query.css("#submission-options", visible: false))
  end

  defp assert_change(session, count, key, params, entries) do
    session
    |> assert_has(Query.css("#submission-state[data-change-count='#{count}']", visible: :any))
    |> execute_script(
      """
      return {
        params: JSON.parse(document.querySelector('#submission-state').dataset.change),
        events: window.selectionEvents
      };
      """,
      fn result ->
        assert result["params"] == Map.put(params, "_target", [key])
        assert length(result["events"]) == count * 2

        assert Enum.take(result["events"], -2) == [
                 %{"type" => "input", "sameControl" => true, "entries" => entries},
                 %{"type" => "change", "sameControl" => true, "entries" => entries}
               ]
      end
    )
  end
end
