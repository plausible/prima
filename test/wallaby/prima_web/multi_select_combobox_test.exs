defmodule PrimaWeb.MultiSelectComboboxTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#demo-multi-select-combobox")
  @search_input Query.css("#demo-multi-select-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#demo-multi-select-combobox [data-prima-ref=options]")
  @all_options Query.css("#demo-multi-select-combobox [role=option]")

  feature "combobox has data-multiple attribute", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> execute_script(
      "return document.querySelector('#demo-multi-select-combobox').hasAttribute('data-multiple')",
      fn has_attr ->
        assert has_attr == true, "Expected data-multiple attribute to be present"
      end
    )
  end

  feature "shows combobox options when input is focused", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> assert_has(@combobox_container)
    |> assert_has(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(4))
  end

  feature "selects multiple options via click", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Options should close after selection in multi-select mode
    |> assert_has(@options_container |> Query.visible(false))
    # Re-open to select another option
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Re-open to verify both options are marked as selected
    |> click(@search_input)
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [role=option][data-value='Apple'][data-selected=true]"
      )
    )
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [role=option][data-value='Banana'][data-selected=true]"
      )
    )
  end

  feature "selects multiple options via keyboard", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # First option (Apple) should be focused by default
    |> assert_has(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Apple'][data-focus=true]")
    )
    # Select with Enter
    |> send_keys([:enter])
    # Options should close
    |> assert_has(@options_container |> Query.visible(false))
    # Re-open for next selection
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Navigate to next option
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Banana'][data-focus=true]")
    )
    # Select with Tab
    |> send_keys([:tab])
    # Options should close
    |> assert_has(@options_container |> Query.visible(false))
    # Re-open to verify both options are marked as selected
    |> click(@search_input)
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [role=option][data-value='Apple'][data-selected=true]"
      )
    )
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [role=option][data-value='Banana'][data-selected=true]"
      )
    )
  end

  feature "search input clears after each selection", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "App")
    |> assert_has(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Search input should be cleared
    |> execute_script(
      "return document.querySelector('#demo-multi-select-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "", "Expected search input to be cleared, got '#{value}'"
      end
    )
  end

  feature "selection pills render correctly", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Verify selection pill is rendered
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
    )
    # Re-open to select another option
    |> click(@search_input)
    # Select another option
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    # Verify both pills are rendered
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
    )
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana']"
      )
    )
  end

  feature "remove button removes selection pill", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    # Both pills should be present
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
    )
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana']"
      )
    )
    # Click remove button for Apple
    |> click(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple'] [data-prima-ref='remove-selection']"
      )
    )
    # Apple pill should be removed
    |> assert_missing(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
    )
    # Banana pill should still be present
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana']"
      )
    )
    # Apple option should no longer be marked as selected
    |> click(@search_input)
    |> assert_missing(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Apple'][data-selected]")
    )
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [role=option][data-value='Banana'][data-selected=true]"
      )
    )
  end

  feature "hidden input array updates correctly", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    # Verify hidden inputs are created
    |> execute_script(
      """
      const inputs = Array.from(document.querySelectorAll('#demo-multi-select-combobox input[type=hidden][name="demo-multi-select-combobox[fruits][]"]'));
      return inputs.map(i => i.value);
      """,
      fn values ->
        assert Enum.sort(values) == ["Apple", "Banana"],
               "Expected hidden inputs to have values ['Apple', 'Banana'], got #{inspect(values)}"
      end
    )
  end

  feature "backspace removes last selection when input is empty", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Cherry']"))
    # All three pills should be present
    |> assert_has(
      Query.css("#demo-multi-select-combobox [data-prima-ref='selection-item']")
      |> Query.count(3)
    )
    # Focus the search input to ensure it receives the key event
    |> click(@search_input)
    # Press backspace (input is already empty after selections)
    |> send_keys([:backspace])
    # Cherry (last selection) should be removed
    |> assert_missing(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Cherry']"
      )
    )
    # Apple and Banana should still be present
    |> assert_has(
      Query.css("#demo-multi-select-combobox [data-prima-ref='selection-item']")
      |> Query.count(2)
    )
  end

  feature "backspace does not remove selection when input has text", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Type some text
    |> fill_in(@search_input, with: "Ban")
    # Press backspace
    |> send_keys([:backspace])
    # Apple pill should still be present (backspace only deleted text)
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
    )
  end

  feature "frontend filtering works with selections", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Type to filter remaining options
    |> fill_in(@search_input, with: "Man")
    # Should show Mango but not Apple, Banana, or Cherry
    |> assert_has(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Mango']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Cherry']")
      |> Query.visible(true)
    )
  end

  feature "cannot select the same option twice", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Re-open to try to select Apple again
    |> click(@search_input)
    # Try to select Apple again
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Should only have one Apple pill
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
      |> Query.count(1)
    )
    # Should only have one hidden input for Apple
    |> execute_script(
      """
      const inputs = Array.from(document.querySelectorAll('#demo-multi-select-combobox input[type=hidden][value="Apple"]'));
      return inputs.length;
      """,
      fn count ->
        assert count == 1, "Expected only 1 hidden input for Apple, got #{count}"
      end
    )
  end

  feature "multiple data-selected attributes on options", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Cherry']"))
    # Re-open to verify all three selected options have data-selected=true
    |> click(@search_input)
    # All three selected options should have data-selected=true
    |> assert_has(
      Query.css("#demo-multi-select-combobox [role=option][data-selected=true]")
      |> Query.count(3)
    )
    # Mango should not have data-selected
    |> assert_missing(
      Query.css("#demo-multi-select-combobox [role=option][data-value='Mango'][data-selected]")
    )
  end

  feature "hidden inputs update when selection is removed", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    # Remove Banana
    |> click(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana'] [data-prima-ref='remove-selection']"
      )
    )
    # Verify only Apple hidden input remains
    |> execute_script(
      """
      const inputs = Array.from(document.querySelectorAll('#demo-multi-select-combobox input[type=hidden][name="demo-multi-select-combobox[fruits][]"]'));
      return inputs.map(i => i.value);
      """,
      fn values ->
        assert values == ["Apple"],
               "Expected hidden inputs to have values ['Apple'], got #{inspect(values)}"
      end
    )
  end

  feature "closes options and focuses input after selection in multi-select mode", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select an option
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    # Options should close after selection
    |> assert_has(@options_container |> Query.visible(false))
    # Search input should be focused
    |> execute_script(
      "return document.activeElement === document.querySelector('#demo-multi-select-combobox input[data-prima-ref=search_input]')",
      fn is_focused ->
        assert is_focused == true, "Expected search input to be focused after selection"
      end
    )
  end

  feature "clicking search input toggles options visibility", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    # Initially options are hidden
    |> assert_has(@options_container |> Query.visible(false))
    # Click to open
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click again to close
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    # Click again to open
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
  end

  feature "clicking remove button keeps input focused", %{session: session} do
    session
    |> visit_fixture("/fixtures/multi-select-combobox", "#demo-multi-select-combobox")
    |> click(@search_input)
    # Select two options
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Apple']"))
    |> click(@search_input)
    |> click(Query.css("#demo-multi-select-combobox [role=option][data-value='Banana']"))
    # Both pills should be present
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Apple']"
      )
    )
    |> assert_has(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana']"
      )
    )
    # Click remove button for Banana
    |> click(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana'] [data-prima-ref='remove-selection']"
      )
    )
    # Banana pill should be removed
    |> assert_missing(
      Query.css(
        "#demo-multi-select-combobox [data-prima-ref='selection-item'][data-value='Banana']"
      )
    )
    # Search input should still be focused
    |> execute_script(
      "return document.activeElement === document.querySelector('#demo-multi-select-combobox input[data-prima-ref=search_input]')",
      fn is_focused ->
        assert is_focused == true,
               "Expected search input to remain focused after clicking remove button"
      end
    )
  end
end
