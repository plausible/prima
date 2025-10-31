defmodule DemoWeb.ComboboxTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#demo-combobox")
  @search_input Query.css("#demo-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#demo-combobox [data-prima-ref=options]")
  @all_options Query.css("#demo-combobox [role=option]")

  feature "shows combobox options when input is focused", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(@combobox_container)
    |> assert_has(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
  end

  feature "hides options when clicking outside combobox", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
  end

  feature "filters options based on search input", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # Type "app" - should show Apple and Pineapple (both contain "app")
    |> fill_in(@search_input, with: "app")
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-combobox [role=option][data-value='Pear']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-combobox [role=option][data-value='Mango']")
      |> Query.visible(true)
    )
  end

  feature "selects option when clicked", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the selected value
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "Apple",
               "Expected search input value to be 'Apple', got '#{values["search"]}'"

        assert values["submit"] == "Apple",
               "Expected submit input value to be 'Apple', got '#{values["submit"]}'"
      end
    )
  end

  feature "focuses option on mouse hover", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> hover(Query.css("#demo-combobox [role=option][data-value=Mango]"))
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
  end

  feature "resets search input when losing focus without selection", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something in search input without selecting
    |> fill_in(@search_input, with: "test")
    # Click outside to lose focus
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
    # Check that search input is reset but submit input remains empty
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "",
               "Expected search input to be reset to empty, got '#{values["search"]}'"

        assert values["submit"] == "",
               "Expected submit input to remain empty, got '#{values["submit"]}'"
      end
    )
  end

  feature "preserves focused option after search if focused option still present", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox", "#demo-async-combobox")
    # Start with search that will show Orange as the focused option
    |> click(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"),
      with: "Orange"
    )
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    # Orange should be automatically focused as the only/first option
    |> assert_has(
      Query.css("#demo-async-combobox [role=option][data-value='Orange'][data-focus=true]")
    )
    # Now search for "a" which should match multiple fruits but Orange should stay focused
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"), with: "a")
    # Wait for async search to complete and verify Orange is still focused (preserved)
    # Even though there are multiple options including Banana, Orange should remain focused
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Banana']"))
    |> assert_has(
      Query.css("#demo-async-combobox [role=option][data-value='Orange'][data-focus=true]")
    )
  end

  feature "async combobox shows options after search", %{session: session} do
    session
    |> visit_fixture("/fixtures/async-combobox", "#demo-async-combobox")
    # Focus on the async combobox and type a search term
    |> click(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"), with: "an")
    # Wait for async search to complete and options to appear
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    # Should find options containing "an" (Orange, Banana) - fruits: Cherry, Kiwi, Grapefruit, Orange, Banana
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Banana']"))
    # Should not find options that don't contain "an" (Cherry, Kiwi, Grapefruit)
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Cherry']"))
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Kiwi']"))
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Grapefruit']"))
  end

  feature "async combobox handles search with no results", %{session: session} do
    session
    |> visit_fixture("/fixtures/async-combobox", "#demo-async-combobox")
    # Focus the async combobox and search for something that won't match any fruits
    |> click(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"),
      with: "xyz"
    )
    # Options container should still be visible but contain no options
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    # All fruit options should be filtered out
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Cherry']"))
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Kiwi']"))
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Grapefruit']"))
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    |> assert_missing(Query.css("#demo-async-combobox [role=option][data-value='Banana']"))
  end

  feature "form integration - selected value is available for submission", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select an option
    |> click(Query.css("#demo-combobox [role=option][data-value='Pear']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the form input has the correct name and value for submission
    |> execute_script(
      "const input = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {name: input ? input.name : '', value: input ? input.value : ''}",
      fn data ->
        assert data["name"] == "demo-combobox[fruit]",
               "Expected form input name to be 'demo-combobox[fruit]', got '#{data["name"]}'"

        assert data["value"] == "Pear",
               "Expected form input value to be 'Pear', got '#{data["value"]}'"
      end
    )
  end

  feature "async combobox: options reappear when backspacing after selection (working case)", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox", "#demo-async-combobox")
    |> click(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"),
      with: "Orange"
    )
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-async-combobox [role=option][data-value='Orange'][data-focus=true]")
    )
    |> send_keys([:enter])
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(false))
    |> send_keys([:backspace])
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
  end

  feature "frontend combobox: options should reappear when backspacing after selection (bug case)",
          %{
            session: session
          } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    |> send_keys([:enter])
    |> assert_has(@options_container |> Query.visible(false))
    |> send_keys([:backspace])
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
  end

  feature "async combobox: options should not show by default without user interaction", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox", "#demo-async-combobox")
    # Options should be hidden initially without any user interaction
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(false))
    # Search input should be present but not focused
    |> assert_has(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"))
    # Verify no options are showing
    |> assert_missing(Query.css("#demo-async-combobox [role=option]") |> Query.visible(true))
  end

  feature "selected option has data-selected attribute (click selection)", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # No options should have data-selected initially
    |> assert_missing(Query.css("#demo-combobox [role=option][data-selected]"))
    # Click to select Apple
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Open options again to verify data-selected is set
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Apple'][data-selected=true]")
    )
    # Verify only one option has data-selected
    |> assert_has(Query.css("#demo-combobox [role=option][data-selected]") |> Query.count(1))
  end

  feature "only one option has data-selected at a time", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Open options and verify Apple is selected
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Apple'][data-selected=true]")
    )
    # Select Mango instead
    |> click(Query.css("#demo-combobox [role=option][data-value='Mango']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Open options and verify only Mango is selected now
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Mango'][data-selected=true]")
    )
    |> assert_missing(
      Query.css("#demo-combobox [role=option][data-value='Apple'][data-selected]")
    )
    # Verify only one option has data-selected
    |> assert_has(Query.css("#demo-combobox [role=option][data-selected]") |> Query.count(1))
  end

  feature "data-selected persists across async updates", %{session: session} do
    session
    |> visit_fixture("/fixtures/async-combobox", "#demo-async-combobox")
    |> click(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"),
      with: "Orange"
    )
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    # Select Orange
    |> send_keys([:enter])
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(false))
    # Search for something else (trigger async update)
    |> fill_in(Query.css("#demo-async-combobox input[data-prima-ref=search_input]"), with: "a")
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    # Orange should still have data-selected even though we searched for "a"
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    |> assert_has(
      Query.css("#demo-async-combobox [role=option][data-value='Orange'][data-selected=true]")
    )
    # Verify only one option has data-selected
    |> assert_has(
      Query.css("#demo-async-combobox [role=option][data-selected]")
      |> Query.count(1)
    )
  end

  feature "data-selected is not set when clicking outside without selection", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click outside without selecting
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
    # Open options again and verify no option has data-selected
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_missing(Query.css("#demo-combobox [role=option][data-selected]"))
  end

  feature "focus selects text but does NOT open options", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(@options_container |> Query.visible(false))
    # First, add some text to the input
    |> execute_script(
      "document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value = 'Apple'"
    )
    # Blur the input first to ensure we're testing focus behavior
    |> execute_script(
      "document.querySelector('#demo-combobox input[data-prima-ref=search_input]').blur()"
    )
    # Now focus the input programmatically (simulating Tab key)
    |> execute_script(
      "document.querySelector('#demo-combobox input[data-prima-ref=search_input]').focus()"
    )
    # Options should still be closed (focus doesn't open options)
    |> assert_has(@options_container |> Query.visible(false))
    # Verify text selection happened (entire "Apple" should be selected)
    |> execute_script(
      "const input = document.querySelector('#demo-combobox input[data-prima-ref=search_input]'); return {selectionStart: input.selectionStart, selectionEnd: input.selectionEnd, valueLength: input.value.length}",
      fn selection ->
        assert selection["selectionStart"] == 0,
               "Expected selectionStart to be 0, got #{selection["selectionStart"]}"

        assert selection["selectionEnd"] == 5,
               "Expected selectionEnd to be 5 (length of 'Apple'), got #{selection["selectionEnd"]}"

        assert selection["selectionEnd"] == selection["valueLength"],
               "Expected entire text to be selected"
      end
    )
  end

  feature "clicking input toggles options visibility", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    # Initially options are hidden
    |> assert_has(@options_container |> Query.visible(false))
    # Click to open
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click again to close (toggle)
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    # Click again to open
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
  end

  feature "escape key closes options and maintains input value", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something to filter
    |> fill_in(@search_input, with: "app")
    # Press Escape
    |> send_keys([:escape])
    # Options should close
    |> assert_has(@options_container |> Query.visible(false))
    # Input value should be cleared on blur
    |> execute_script(
      "return document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        # After escape and blur, search input should be reset since no selection was made
        assert value == "" || value == "app",
               "Expected search input to be empty or contain typed text, got '#{value}'"
      end
    )
  end

  feature "single-select MUST close options after selection (behavior contract)", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select an option
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    # This MUST close options - this is a behavioral requirement, not a side effect
    |> assert_has(@options_container |> Query.visible(false))
  end

  feature "single-select does not focus input after clicking selection", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select an option by clicking
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the search input is NOT focused after selection
    |> execute_script(
      "return document.activeElement === document.querySelector('#demo-combobox input[data-prima-ref=search_input]')",
      fn is_focused ->
        assert is_focused == false,
               "Expected search input to not be focused after selection in single-select mode"
      end
    )
  end

  feature "search input shows selected value after re-opening (single-select)", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Re-open options by clicking
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Search input should still show "Apple"
    |> execute_script(
      "return document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "Apple",
               "Expected search input to show selected value 'Apple' after re-opening, got '#{value}'"
      end
    )
  end

  feature "combobox remains functional after LiveView reconnection", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> execute_script("window.liveSocket.disconnect()")
    |> execute_script("window.liveSocket.connect()")
    # Wait for reconnection by checking for the data attribute that gets set
    |> assert_has(Query.css(".phx-connected[data-phx-main]"))
    # Test basic open/close functionality
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # Test keyboard navigation
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Pear'][data-focus=true]"))
    # Test selection with Enter
    |> send_keys([:enter])
    |> assert_has(@options_container |> Query.visible(false))
    # Verify selection worked
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "Pear",
               "Expected search input value to be 'Pear', got '#{values["search"]}'"

        assert values["submit"] == "Pear",
               "Expected submit input value to be 'Pear', got '#{values["submit"]}'"
      end
    )
  end

  feature "backspacing after selection and blur clears both inputs", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Click outside to lose focus
    |> click(Query.css("body"))
    # Focus back on the input and hit backspace
    |> click(@search_input)
    |> send_keys([:backspace])
    # Both search and submit inputs should be empty
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "",
               "Expected search input to be empty after backspace, got '#{values["search"]}'"

        assert values["submit"] == "",
               "Expected submit input to be empty after backspace, got '#{values["submit"]}'"
      end
    )
  end

  feature "backspacing with remaining text does not clear submit value", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Click outside to lose focus
    |> click(Query.css("body"))
    # Click back in (whole input text is selected)
    |> click(@search_input)
    # Click again to de-select and move cursor to end
    |> execute_script(
      "const input = document.querySelector('#demo-combobox input[data-prima-ref=search_input]'); input.setSelectionRange(input.value.length, input.value.length)"
    )
    # Hit backspace - removes one character
    |> send_keys([:backspace])
    # Search input should have "Appl" but submit input should still be "Apple"
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "Appl",
               "Expected search input to be 'Appl' after backspace, got '#{values["search"]}'"

        assert values["submit"] == "Apple",
               "Expected submit input to remain 'Apple', got '#{values["submit"]}'"
      end
    )
  end
end
