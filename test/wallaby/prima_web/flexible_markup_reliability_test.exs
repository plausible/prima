defmodule PrimaWeb.FlexibleMarkupReliabilityTest do
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
    |> execute_script(
      "const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return hiddenInput ? hiddenInput.value : ''",
      fn value ->
        assert value == "urgent", "Direct click on option should work, got: '#{value}'"
      end
    )
    # Reset for next test
    |> click(@search_input)
    |> fill_in(@search_input, with: "")
    |> execute_script(
      "const container = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container]'); if (container) container.innerHTML = ''"
    )
    # Now try clicking on the SVG icon - this should now work with the fix
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='medium'] svg"))
    |> execute_script(
      "const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return hiddenInput ? hiddenInput.value : ''",
      fn value ->
        # This should now work with event delegation fix
        assert value == "medium", "Clicking on SVG should select option, but got: '#{value}'"
      end
    )
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
    |> execute_script(
      "const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return hiddenInput ? hiddenInput.value : ''",
      fn value ->
        assert value == "high", "Clicking nested text should work, got: '#{value}'"
      end
    )
    # Reset and test clicking on the low option directly
    |> click(@search_input)
    |> fill_in(@search_input, with: "")
    |> execute_script(
      "const container = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container]'); if (container) container.innerHTML = ''"
    )
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='low']"))
    |> execute_script(
      "const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return hiddenInput ? hiddenInput.value : ''",
      fn value ->
        assert value == "low", "Clicking low option should work, got: '#{value}'"
      end
    )
  end
end
