defmodule PrimaWeb.ComboboxKeyboardNavigationTest do
  use Prima.WallabyCase, async: true

  @search_input Query.css("#demo-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#demo-combobox [data-prima-ref=options]")
  @all_options Query.css("#demo-combobox [role=option]")

  feature "navigates options with keyboard arrows", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
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

  feature "keyboard navigation wrapping (last to first, first to last)", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # First option should be focused by default
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Arrow up from first should wrap to last (Pineapple)
    |> send_keys([:up_arrow])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
    # Arrow down from last should wrap to first
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "selects focused option with Enter key", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
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

  feature "selects focused option with Tab key", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
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
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "Mango",
               "Expected search input value to be 'Mango', got '#{values["search"]}'"

        assert values["submit"] == "Mango",
               "Expected submit input value to be 'Mango', got '#{values["submit"]}'"
      end
    )
  end

  feature "ArrowDown opens combobox when closed and input is focused", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    # Options are closed initially
    |> assert_has(@options_container |> Query.visible(false))
    # Focus the input without opening options (programmatically, simulating Tab key)
    |> execute_script(
      "document.querySelector('#demo-combobox input[data-prima-ref=search_input]').focus()"
    )
    # Options should still be closed after focus
    |> assert_has(@options_container |> Query.visible(false))
    # Press ArrowDown - should open options and focus first item
    |> send_keys([:down_arrow])
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "ArrowUp opens combobox when closed and input is focused", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    # Options are closed initially
    |> assert_has(@options_container |> Query.visible(false))
    # Focus the input without opening options
    |> execute_script(
      "document.querySelector('#demo-combobox input[data-prima-ref=search_input]').focus()"
    )
    # Options should still be closed after focus
    |> assert_has(@options_container |> Query.visible(false))
    # Press ArrowUp - should open options and focus first item
    |> send_keys([:up_arrow])
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "Home key jumps to first option", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # First option should be focused by default (Apple)
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Navigate down a few times
    |> send_keys([:down_arrow, :down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
    # Press Home to jump back to first
    |> send_keys([:home])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "End key jumps to last option", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # First option should be focused by default (Apple)
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Press End to jump to last option (Pineapple)
    |> send_keys([:end])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
  end

  feature "PageUp key jumps to first option", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # Navigate to third option
    |> send_keys([:down_arrow, :down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
    # Press PageUp to jump to first
    |> send_keys([:pageup])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "PageDown key jumps to last option", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
    # First option should be focused by default
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Press PageDown to jump to last option
    |> send_keys([:pagedown])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
  end

  feature "Home/End work correctly with filtered options", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type "app" to filter - should show Apple and Pineapple
    |> fill_in(@search_input, with: "app")
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple']")
      |> Query.visible(true)
    )
    # First visible option (Apple) should be focused
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Press End to jump to last visible option (Pineapple)
    |> send_keys([:end])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
    # Press Home to jump back to first visible option (Apple)
    |> send_keys([:home])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "Escape key restores previously selected value in single-select", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#demo-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify Apple is in the search input
    |> execute_script(
      "return document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "Apple", "Expected search input to show 'Apple', got '#{value}'"
      end
    )
    # Open options again
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something else
    |> fill_in(@search_input, with: "xyz")
    # Press Escape - should restore "Apple"
    |> send_keys([:escape])
    |> assert_has(@options_container |> Query.visible(false))
    # Verify Apple is restored in search input
    |> execute_script(
      "return document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "Apple",
               "Expected search input to be restored to 'Apple' after Escape, got '#{value}'"
      end
    )
  end

  feature "Escape key clears search input when no previous selection exists", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something without selecting
    |> fill_in(@search_input, with: "test")
    # Press Escape
    |> send_keys([:escape])
    |> assert_has(@options_container |> Query.visible(false))
    # Search input should be cleared since there was no previous selection
    |> execute_script(
      "return document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "",
               "Expected search input to be empty after Escape with no selection, got '#{value}'"
      end
    )
  end

  feature "Escape key clears search input in multi-select mode", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(Query.css("#demo-multi-select-combobox input[data-prima-ref=search_input]"))
    |> assert_has(
      Query.css("#demo-multi-select-combobox [data-prima-ref=options]")
      |> Query.visible(true)
    )
    # Type something
    |> fill_in(Query.css("#demo-multi-select-combobox input[data-prima-ref=search_input]"),
      with: "test"
    )
    # Press Escape
    |> send_keys([:escape])
    |> assert_has(
      Query.css("#demo-multi-select-combobox [data-prima-ref=options]")
      |> Query.visible(false)
    )
    # Search input should be cleared in multi-select mode
    |> execute_script(
      "return document.querySelector('#demo-multi-select-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "",
               "Expected search input to be empty after Escape in multi-select, got '#{value}'"
      end
    )
  end

  feature "Home/End/PageUp/PageDown only work when options are open", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    # Options are closed initially
    |> assert_has(@options_container |> Query.visible(false))
    # Focus the input
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Close options with Escape
    |> send_keys([:escape])
    # Wait for options to be hidden (using Wallaby's visibility check which waits)
    |> assert_has(@options_container |> Query.visible(false))
    # Now pressing Home/End should not cause errors (just do nothing)
    # This is a regression test - we just want to make sure no errors occur
    |> send_keys([:home])
    |> send_keys([:end])
    |> send_keys([:pageup])
    |> send_keys([:pagedown])
    # Verify options are still closed
    |> assert_has(@options_container |> Query.visible(false))
  end

  feature "combined navigation: arrow keys, Home, and End work together seamlessly", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Start at first option (Apple)
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Jump to end
    |> send_keys([:end])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
    # Arrow up one
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Mango'][data-focus=true]"))
    # Jump to start
    |> send_keys([:home])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
    # Arrow down one
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Pear'][data-focus=true]"))
    # PageDown to last
    |> send_keys([:pagedown])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
    # PageUp to first
    |> send_keys([:pageup])
    |> assert_has(Query.css("#demo-combobox [role=option][data-value='Apple'][data-focus=true]"))
  end

  feature "selection with Enter works after using Home/End navigation", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Jump to last with End
    |> send_keys([:end])
    |> assert_has(
      Query.css("#demo-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
    # Select with Enter
    |> send_keys([:enter])
    |> assert_has(@options_container |> Query.visible(false))
    # Verify selection
    |> execute_script(
      "const searchVal = document.querySelector('#demo-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#demo-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "Pineapple",
               "Expected search input value to be 'Pineapple', got '#{values["search"]}'"

        assert values["submit"] == "Pineapple",
               "Expected submit input value to be 'Pineapple', got '#{values["submit"]}'"
      end
    )
  end

  feature "focused option scrolls into view when using up arrow in overflow container", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/overflow-combobox", "#overflow-combobox")
    |> click(Query.css("#overflow-combobox input[data-prima-ref=search_input]"))
    |> assert_has(Query.css("#overflow-combobox-options") |> Query.visible(true))
    # First option should be focused by default
    |> assert_has(
      Query.css("#overflow-combobox [role=option][data-value='Item 1'][data-focus=true]")
    )
    # Press up arrow to wrap to last option (Item 50)
    |> send_keys([:up_arrow])
    |> assert_has(
      Query.css("#overflow-combobox [role=option][data-value='Item 50'][data-focus=true]")
    )
    # Verify that Item 50 is visible (scrolled into view)
    |> execute_script(
      """
      const option = document.querySelector('#overflow-combobox [role=option][data-value=\"Item 50\"]');
      const container = document.querySelector('#overflow-combobox-options');
      const optionRect = option.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();
      return {
        isVisible: optionRect.top >= containerRect.top && optionRect.bottom <= containerRect.bottom,
        optionTop: optionRect.top,
        optionBottom: optionRect.bottom,
        containerTop: containerRect.top,
        containerBottom: containerRect.bottom
      };
      """,
      fn result ->
        assert result["isVisible"] == true,
               "Expected Item 50 to be scrolled into view. Option top: #{result["optionTop"]}, bottom: #{result["optionBottom"]}, Container top: #{result["containerTop"]}, bottom: #{result["containerBottom"]}"
      end
    )
  end

  feature "scroll position resets when reopening combobox after navigating to bottom", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/overflow-combobox", "#overflow-combobox")
    # Open combobox
    |> click(Query.css("#overflow-combobox input[data-prima-ref=search_input]"))
    |> assert_has(Query.css("#overflow-combobox-options") |> Query.visible(true))
    # Navigate to last option with up arrow
    |> send_keys([:up_arrow])
    |> assert_has(
      Query.css("#overflow-combobox [role=option][data-value='Item 50'][data-focus=true]")
    )
    # Close combobox
    |> send_keys([:escape])
    |> assert_has(Query.css("#overflow-combobox-options") |> Query.visible(false))
    # Reopen combobox
    |> click(Query.css("#overflow-combobox input[data-prima-ref=search_input]"))
    |> assert_has(Query.css("#overflow-combobox-options") |> Query.visible(true))
    # First option should be focused
    |> assert_has(
      Query.css("#overflow-combobox [role=option][data-value='Item 1'][data-focus=true]")
    )
    # Verify that Item 1 is visible (container scrolled to top)
    |> execute_script(
      """
      const option = document.querySelector('#overflow-combobox [role=option][data-value=\"Item 1\"]');
      const container = document.querySelector('#overflow-combobox-options');
      const optionRect = option.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();
      return {
        isVisible: optionRect.top >= containerRect.top && optionRect.bottom <= containerRect.bottom,
        optionTop: optionRect.top,
        optionBottom: optionRect.bottom,
        containerTop: containerRect.top,
        containerBottom: containerRect.bottom,
        scrollTop: container.scrollTop
      };
      """,
      fn result ->
        assert result["isVisible"] == true,
               "Expected Item 1 to be scrolled into view. Option top: #{result["optionTop"]}, bottom: #{result["optionBottom"]}, Container top: #{result["containerTop"]}, bottom: #{result["containerBottom"]}, scrollTop: #{result["scrollTop"]}"
      end
    )
  end
end
