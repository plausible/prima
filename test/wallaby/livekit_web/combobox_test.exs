defmodule LiveKitWeb.ComboboxTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @combobox_container Query.css("#demo-combobox")
  @search_input Query.css("#demo-combobox input[data-livekit-ref=search_input]")
  @options_container Query.css("#demo-combobox [data-livekit-ref=options]")
  @all_options Query.css("#demo-combobox [role=option]")

  feature "shows combobox options when input is focused", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> assert_has(@combobox_container)
    |> assert_has(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
  end

  feature "hides options when clicking outside combobox", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
  end

  # TODO: Fix filtering behavior - combobox seems to be in async mode
  # feature "filters options based on search input", %{session: session} do

  feature "selects option when clicked", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the selected value
    # Both inputs are set the same way in JavaScript, so use execute_script for consistency
    |> execute_script("return {search: document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').value, submit: document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]').value}", fn values ->
      assert values["search"] == "Apple", "Expected search input value to be 'Apple', got '#{values["search"]}'"
      assert values["submit"] == "Apple", "Expected submit input value to be 'Apple', got '#{values["submit"]}'"
    end)
  end

  feature "navigates options with keyboard arrows", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # First option should be focused by default
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Arrow down to next option - use correct key codes and send to the focused element
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Pear'][data-focus=true]"))
    # Arrow down again
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
    # Arrow up back to previous
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Pear'][data-focus=true]"))
  end

  feature "selects focused option with Enter key", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Navigate to second option
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Pear'][data-focus=true]"))
    # Select with Enter
    |> send_keys([:enter])
    # Options should be hidden after selection
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the selected value
    # Both inputs are set the same way in JavaScript, so use execute_script for consistency
    |> execute_script("return {search: document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').value, submit: document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]').value}", fn values ->
      assert values["search"] == "Pear", "Expected search input value to be 'Pear', got '#{values["search"]}'"
      assert values["submit"] == "Pear", "Expected submit input value to be 'Pear', got '#{values["submit"]}'"
    end)
  end

  feature "selects focused option with Tab key", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Navigate to third option
    |> send_keys([:down_arrow, :down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
    # Select with Tab
    |> send_keys([:tab])
    # Options should be hidden after selection
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the selected value
    # Both inputs are set the same way in JavaScript, so use execute_script for consistency
    |> execute_script("return {search: document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').value, submit: document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]').value}", fn values ->
      assert values["search"] == "Mango", "Expected search input value to be 'Mango', got '#{values["search"]}'"
      assert values["submit"] == "Mango", "Expected submit input value to be 'Mango', got '#{values["submit"]}'"
    end)
  end

  feature "focuses option on mouse hover", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Simulate hover with JavaScript since Wallaby mouse interactions are limited
    |> execute_script("document.querySelector('#demo-combobox [role=option][data-value=\"Mango\"]').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))")
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
  end

  feature "resets search input when losing focus without selection", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something in search input without selecting
    |> fill_in(@search_input, with: "test")
    # Click outside to lose focus
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
    # Check that search input is reset but submit input remains empty
    |> execute_script("return {search: document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').value, submit: document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]').value}", fn values ->
      assert values["search"] == "", "Expected search input to be reset to empty, got '#{values["search"]}'"
      assert values["submit"] == "", "Expected submit input to remain empty, got '#{values["submit"]}'"
    end)
  end

  feature "preserves selected value after clicking outside and refocusing", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select an option
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Click outside to trigger resetOnBlur behavior
    |> click(Query.css("body"))
    # Verify that selected values are preserved after the resetOnBlur logic runs
    |> execute_script("return {search: document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').value, submit: document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]').value}", fn values ->
      assert values["search"] == "Apple", "Expected search input to preserve selected value 'Apple' after clicking outside, got '#{values["search"]}'"
      assert values["submit"] == "Apple", "Expected submit input to preserve selected value 'Apple' after clicking outside, got '#{values["submit"]}'"
    end)
    # Focus the input again - use execute_script because Wallaby's click() doesn't reliably trigger focus events in this complex scenario
    |> execute_script("document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').focus()")
    |> assert_has(@options_container |> Query.visible(true))
    # Confirm values remain intact after refocusing
    |> execute_script("return {search: document.querySelector('#demo-combobox input[data-livekit-ref=search_input]').value, submit: document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]').value}", fn values ->
      assert values["search"] == "Apple", "Expected search input to preserve selected value 'Apple' after refocus, got '#{values["search"]}'"
      assert values["submit"] == "Apple", "Expected submit input to preserve selected value 'Apple' after refocus, got '#{values["submit"]}'"
    end)
  end


  feature "async combobox shows options after search", %{session: session} do
    session
    |> visit("/demo/combobox")
    # Focus on the async combobox and type a search term
    |> click(Query.css("#demo-async-combobox input[data-livekit-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-livekit-ref=search_input]"), with: "an")
    # Wait for async search to complete and options to appear
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    # Should find options containing "an" (Orange, Banana) - fruits: Cherry, Kiwi, Grapefruit, Orange, Banana
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    |> assert_has(Query.css("#demo-async-combobox [role=option][data-value='Banana']"))
    # Should not find options that don't contain "an" (Cherry, Kiwi, Grapefruit)
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Cherry']"))
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Kiwi']"))
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Grapefruit']"))
  end

  feature "async combobox handles search with no results", %{session: session} do
    session
    |> visit("/demo/combobox")
    # Focus the async combobox and search for something that won't match any fruits
    |> click(Query.css("#demo-async-combobox input[data-livekit-ref=search_input]"))
    |> fill_in(Query.css("#demo-async-combobox input[data-livekit-ref=search_input]"), with: "xyz")
    # Options container should still be visible but contain no options
    |> assert_has(Query.css("#demo-async-combobox-options") |> Query.visible(true))
    # All fruit options should be filtered out
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Cherry']"))
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Kiwi']"))
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Grapefruit']"))
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Orange']"))
    |> refute_has(Query.css("#demo-async-combobox [role=option][data-value='Banana']"))
  end

  feature "keyboard navigation wrapping (last to first, first to last)", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # First option should be focused by default
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Arrow up from first should wrap to last (Pineapple)
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]"))
    # Arrow down from last should wrap to first
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end
  # TODO: Test async search debouncing behavior
  # TODO: Test accessibility features (ARIA attributes, screen reader announcements)
  # TODO: Test edge cases like empty search results
  feature "form integration - selected value is available for submission", %{session: session} do
    session
    |> visit("/demo/combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select an option
    |> click(Query.css("#demo-combobox [role=option][data-value='Pear']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the form input has the correct name and value for submission
    |> execute_script("const input = document.querySelector('#demo-combobox input[data-livekit-ref=submit_input]'); return {name: input.name, value: input.value}", fn data ->
      assert data["name"] == "demo-combobox[fruit]", "Expected form input name to be 'demo-combobox[fruit]', got '#{data["name"]}'"
      assert data["value"] == "Pear", "Expected form input value to be 'Pear', got '#{data["value"]}'"
    end)
  end
end