defmodule PrimaWeb.ComboboxSelectionChangeTest do
  use Prima.WallabyCase, async: true

  @combobox Query.css("#selection-change-combobox")
  @search_input Query.css("#selection-change-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#selection-change-options")
  @selection_display Query.css("#selection-display")

  feature "phx-change event fires when user selects an option", %{session: session} do
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

  feature "phx-change event fires when user changes selection", %{session: session} do
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

  feature "phx-change event fires when selection is made via keyboard", %{session: session} do
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

  feature "phx-change does not fire when clicking outside without selection", %{
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
end
