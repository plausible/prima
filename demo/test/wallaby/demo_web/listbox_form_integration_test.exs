defmodule DemoWeb.ListboxFormIntegrationTest do
  use Prima.WallabyCase, async: true

  @button Query.css("#listbox-form [aria-haspopup=listbox]")
  @listbox Query.css("#listbox-form [role=listbox]")
  @listbox_value Query.css("#listbox-form [data-prima-ref='value']")
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

  feature "the displayed value updates instantly, ahead of the phx-change round-trip", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> assert_has(@listbox_value |> Query.text("Select a fruit..."))
    |> click(@button)
    |> click(Query.css("#listbox-form-option-mango"))
    |> assert_has(@listbox_value |> Query.text("Mango"))
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

  feature "disabling an open listbox closes it and blocks selection until re-enabled", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> click(@button)
    |> click(Query.css("#listbox-form-option-apple"))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    |> click(@button)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#listbox-form-option-apple[data-focus]"))
    # Send the LiveView event without an outside click closing the listbox first.
    |> execute_script("""
    const toggle = document.querySelector('#toggle-listbox-disabled');
    window.liveSocket.execJS(toggle, toggle.getAttribute('phx-click'));
    """)
    |> assert_has(Query.css("#listbox-form-trigger:disabled[aria-expanded=false]"))
    |> assert_has(@listbox |> Query.visible(false))
    |> assert_missing(Query.css("#listbox-form [data-focus]", visible: :any))
    |> assert_missing(Query.css("#listbox-form-trigger:focus"))
    |> execute_script("""
    const options = document.querySelector('#listbox-form-options');
    options.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', bubbles: true}));
    document.querySelector('#listbox-form-option-mango').click();
    """)
    |> assert_has(@listbox_value |> Query.text("Apple"))
    |> assert_form_change_count(1)
    |> click(Query.css("#toggle-listbox-disabled"))
    |> assert_has(Query.css("#listbox-form-trigger:enabled:not([data-disabled])"))
    |> click(@button)
    |> send_keys([:down_arrow, :down_arrow, :enter])
    |> assert_has(@selection_display |> Query.text("Selected: Mango"))
    |> assert_form_change_count(2)
  end

  feature "disabled fields are omitted from submission and retain their value when re-enabled", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox-form", "#listbox-form")
    |> click(@button)
    |> click(Query.css("#listbox-form-option-mango"))
    |> assert_has(@selection_display |> Query.text("Selected: Mango"))
    |> click(Query.css("#toggle-listbox-disabled"))
    |> assert_has(Query.css("#listbox-form-trigger:disabled"))
    |> assert_has(Query.css("#listbox-form input:disabled[value=Mango]", visible: false))
    |> click(Query.css("#submit-listbox-form"))
    |> assert_has(Query.css("#listbox-submission", text: "Submitted: omitted"))
    |> assert_has(Query.css("#listbox-form-trigger:disabled"))
    |> click(Query.css("#toggle-listbox-disabled"))
    |> assert_has(Query.css("#listbox-form-trigger:enabled:not([data-disabled])"))
    |> assert_has(@listbox_value |> Query.text("Mango"))
    |> assert_has(Query.css("#listbox-form input:enabled[value=Mango]", visible: false))
    |> click(Query.css("#submit-listbox-form"))
    |> assert_has(Query.css("#listbox-submission", text: "Submitted: Mango"))
  end
end
