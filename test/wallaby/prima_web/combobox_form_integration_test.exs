defmodule PrimaWeb.ComboboxFormIntegrationTest do
  use Prima.WallabyCase, async: true

  @combobox Query.css("#change-combobox")
  @search_input Query.css("#change-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#change-options")
  @selection_display Query.css("#selection-display")

  defp assert_form_change_count(session, combobox_id, expected_count) do
    session
    |> assert_has(
      Query.css("#{combobox_id} input[data-prima-ref=search_input]:not(.phx-change-loading)")
    )
    |> then(fn session ->
      actual_text = text(session, Query.css("#change-count"))

      assert actual_text == "Form changes: #{expected_count}",
             "Expected form change count to be #{expected_count} but got '#{actual_text}'"

      session
    end)
  end

  feature "phx-change on combobox fires when user selects an option", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    |> assert_has(@combobox)
    # Initially, no selection
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Click to open options
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the selection display was updated via phx-change event
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
  end

  feature "phx-change on combobox fires when user changes selection", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Select Apple first
    |> click(@search_input)
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    # Now select Mango
    |> click(@search_input)
    |> click(Query.css("#change-combobox [role=option][data-value='Mango']"))
    # Verify the selection display was updated to Mango
    |> assert_has(@selection_display |> Query.text("Selected: Mango"))
  end

  feature "phx-change on combobox fires when selection is made via keyboard", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
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
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
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
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Type in search input - should NOT trigger form phx-change
    |> click(Query.css("#change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"), with: "a")
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"), with: "app")
    |> assert_form_change_count("#change-combobox", 0)
    # Now select an option - this SHOULD trigger form phx-change
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_form_change_count("#change-combobox", 1)
    # Type in search again to filter options
    |> click(Query.css("#change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"),
      with: "Pear"
    )
    |> assert_form_change_count("#change-combobox", 1)
    # Now change selection - should increment count to 2
    |> click(Query.css("#change-combobox [role=option][data-value='Pear']"))
    |> assert_form_change_count("#change-combobox", 2)
  end

  feature "search input value persists after selection when form phx-change triggers update", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Type in search input and select an option
    |> click(Query.css("#change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"), with: "app")
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_form_change_count("#change-combobox", 1)
    # Verify the search input still shows the display value "Apple"
    |> then(fn session ->
      input_value =
        session
        |> find(Query.css("#change-combobox input[data-prima-ref=search_input]"))
        |> Element.value()

      assert input_value == "Apple",
             "Expected search input value to be 'Apple' but got '#{input_value}'"

      session
    end)
  end

  feature "async combobox: form phx-change fires only on selection, not on search", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox-form-change", "#async-form-change-combobox")
    # Type in search input - should trigger async search but NOT form phx-change
    |> click(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"),
      with: "an"
    )
    # Wait for async search to complete and show options
    |> assert_has(Query.css("#async-form-change-options") |> Query.visible(true))
    |> assert_has(Query.css("#async-form-change-combobox [role=option][data-value='Orange']"))
    |> assert_form_change_count("#async-form-change-combobox", 0)
    # Now select an option - this SHOULD trigger form phx-change
    |> click(Query.css("#async-form-change-combobox [role=option][data-value='Orange']"))
    |> assert_form_change_count("#async-form-change-combobox", 1)
    # Type again to search - should NOT increment count
    |> click(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"),
      with: "Ba"
    )
    |> assert_has(Query.css("#async-form-change-combobox [role=option][data-value='Banana']"))
    |> assert_form_change_count("#async-form-change-combobox", 1)
    # Change selection - should increment count to 2
    |> click(Query.css("#async-form-change-combobox [role=option][data-value='Banana']"))
    |> assert_form_change_count("#async-form-change-combobox", 2)
  end
end
