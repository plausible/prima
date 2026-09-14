defmodule DemoWeb.ListboxFormIntegrationTest do
  use Prima.WallabyCase, async: true

  @button Query.css("#listbox-form [aria-haspopup=listbox]")
  @listbox Query.css("#listbox-form [role=listbox]")
  @trigger_label Query.css("#listbox-form [data-prima-ref='trigger-label']")
  @selection_display Query.css("#listbox-selection-display")

  defp assert_form_change_count(session, expected_count) do
    actual_text = text(session, Query.css("#listbox-form-change-count"))

    assert actual_text == "Form changes: #{expected_count}",
           "Expected form change count to be #{expected_count} but got '#{actual_text}'"

    session
  end

  feature "phx-change on the parent form fires when an option is selected", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    |> click(Query.css("#listbox-form-option-apple"))
    |> assert_has(@listbox |> Query.visible(false))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    |> assert_form_change_count(1)
    |> assert_has(
      Query.css("#listbox-form-option-apple[aria-selected=true][data-selected]")
      |> Query.visible(false)
    )
  end

  feature "the trigger label updates instantly, ahead of the phx-change round-trip", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> assert_has(@trigger_label |> Query.text("Select a fruit..."))
    |> click(@button)
    |> click(Query.css("#listbox-form-option-mango"))
    |> assert_has(@trigger_label |> Query.text("Mango"))
  end

  feature "phx-change fires again when the selection changes", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> click(@button)
    |> click(Query.css("#listbox-form-option-apple"))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    |> assert_form_change_count(1)
    |> click(@button)
    |> click(Query.css("#listbox-form-option-pineapple"))
    |> assert_has(@selection_display |> Query.text("Selected: Pineapple"))
    |> assert_form_change_count(2)
  end

  feature "phx-change fires when a selection is made via keyboard", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    |> send_keys([:down_arrow])
    |> send_keys([:enter])
    |> assert_has(@listbox |> Query.visible(false))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    |> assert_form_change_count(1)
  end

  feature "does not fire phx-change when closing without selecting", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@listbox |> Query.visible(false))
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    |> assert_form_change_count(0)
  end
end
