defmodule PrimaWeb.ComboboxFormIntegrationTest do
  use Prima.WallabyCase, async: true

  @combobox Query.css("#selection-change-combobox")
  @search_input Query.css("#selection-change-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#selection-change-options")
  @selection_display Query.css("#selection-display")

  feature "phx-change on combobox fires when user selects an option", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-selection-change", "#selection-change-combobox")
    |> assert_has(@combobox)
    # Initially, no selection
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Click to open options
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#selection-change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the selection display was updated via phx-change event
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
  end

  feature "phx-change on combobox fires when user changes selection", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-selection-change", "#selection-change-combobox")
    # Select Apple first
    |> click(@search_input)
    |> click(Query.css("#selection-change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    # Now select Mango
    |> click(@search_input)
    |> click(Query.css("#selection-change-combobox [role=option][data-value='Mango']"))
    # Verify the selection display was updated to Mango
    |> assert_has(@selection_display |> Query.text("Selected: Mango"))
  end

  feature "phx-change on combobox fires when selection is made via keyboard", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-selection-change", "#selection-change-combobox")
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Open options and use keyboard to select
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Press Enter to select the first (focused) option
    |> send_keys([:enter])
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the selection display was updated
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
  end

  feature "phx-change on combobox does not fire when clicking outside without selection", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/combobox-selection-change", "#selection-change-combobox")
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Open options
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click outside without selecting
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
    # Selection display should still show "none"
    |> assert_has(@selection_display |> Query.text("Selected: none"))
  end

  feature "phx-change on parent form fires only on selection, not on search input", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/combobox-form-change", "#form-change-combobox")
    |> assert_has(Query.css("#change-count") |> Query.text("Form changes: 0"))
    # Type in search input - should NOT trigger form phx-change
    |> click(Query.css("#form-change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#form-change-combobox input[data-prima-ref=search_input]"), with: "app")
    # Verify no event fired - count should still be 0
    |> assert_has(Query.css("#change-count") |> Query.text("Form changes: 0"))
    # Now select an option - this SHOULD trigger form phx-change
    |> click(Query.css("#form-change-combobox [role=option][data-value='Apple']"))
    |> assert_has(Query.css("#change-count") |> Query.text("Form changes: 1"))
    # Type in search again to filter options
    |> click(Query.css("#form-change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#form-change-combobox input[data-prima-ref=search_input]"),
      with: "Pear"
    )
    # Verify typing still doesn't increment the count
    |> assert_has(Query.css("#change-count") |> Query.text("Form changes: 1"))
    # Now change selection - should increment count to 2
    |> click(Query.css("#form-change-combobox [role=option][data-value='Pear']"))
    |> assert_has(Query.css("#change-count") |> Query.text("Form changes: 2"))
  end
end
