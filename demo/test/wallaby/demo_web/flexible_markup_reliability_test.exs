defmodule DemoWeb.FlexibleMarkupReliabilityTest do
  use Prima.WallabyCase, async: true

  @search_input Query.css("#flexible-markup-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#flexible-markup-combobox [data-prima-ref=options]")

  feature "verifies the fix: clicking nested elements now works", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Try clicking directly on the option element - this should work
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='urgent']"))
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "urgent", "urgent")
    # Reset for next test
    |> click(@search_input)
    |> send_keys([:backspace])
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "", nil)
    # Now try clicking on the SVG icon - this should now work with the fix
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='medium'] svg"))
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "medium", "medium")
  end

  feature "tests various nested element clicks work with event delegation", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Test clicking on nested text element
    |> click(
      Query.css("#flexible-markup-combobox [role=option][data-value='high'] div div:first-child")
    )
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "high", "high")
    # Reset and test clicking on the low option directly
    |> click(@search_input)
    |> send_keys([:backspace])
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "", nil)
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='low']"))
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "low", "low")
  end
end
