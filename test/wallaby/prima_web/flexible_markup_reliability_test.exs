defmodule PrimaWeb.FlexibleMarkupReliabilityTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#flexible-markup-combobox")
  @search_input Query.css("#flexible-markup-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#flexible-markup-combobox [data-prima-ref=options]")

  feature "verifies the fix: clicking nested elements now works", %{session: session} do
    session
    |> visit("/fixtures/flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Try clicking directly on the option element - this should work
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='urgent']"))
    |> execute_script(
      "return document.querySelector('#flexible-markup-combobox input[data-prima-ref=submit_input]').value",
      fn value ->
        assert value == "urgent", "Direct click on option should work, got: '#{value}'"
      end
    )
    # Reset for next test
    |> click(@search_input)
    |> fill_in(@search_input, with: "")
    |> execute_script(
      "document.querySelector('#flexible-markup-combobox input[data-prima-ref=submit_input]').value = ''"
    )
    # Now try clicking on the SVG icon - this should now work with the fix
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='medium'] svg"))
    |> execute_script(
      "return document.querySelector('#flexible-markup-combobox input[data-prima-ref=submit_input]').value",
      fn value ->
        # This should now work with event delegation fix
        assert value == "medium", "Clicking on SVG should select option, but got: '#{value}'"
      end
    )
  end

  feature "tests various nested element clicks work with event delegation", %{session: session} do
    session
    |> visit("/fixtures/flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Test clicking on nested text element
    |> click(
      Query.css("#flexible-markup-combobox [role=option][data-value='high'] div div:first-child")
    )
    |> execute_script(
      "return document.querySelector('#flexible-markup-combobox input[data-prima-ref=submit_input]').value",
      fn value ->
        assert value == "high", "Clicking nested text should work, got: '#{value}'"
      end
    )
    # Reset and test clicking on the low option directly
    |> click(@search_input)
    |> fill_in(@search_input, with: "")
    |> execute_script(
      "document.querySelector('#flexible-markup-combobox input[data-prima-ref=submit_input]').value = ''"
    )
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='low']"))
    |> execute_script(
      "return document.querySelector('#flexible-markup-combobox input[data-prima-ref=submit_input]').value",
      fn value ->
        assert value == "low", "Clicking low option should work, got: '#{value}'"
      end
    )
  end
end
