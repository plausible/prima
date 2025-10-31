defmodule DemoWeb.FlexibleMarkupComboboxTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#flexible-markup-combobox")
  @search_input Query.css("#flexible-markup-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#flexible-markup-combobox [data-prima-ref=options]")
  @all_options Query.css("#flexible-markup-combobox [role=option]")

  feature "shows combobox options when input is focused", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> assert_has(@combobox_container)
    |> assert_has(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(5))
  end

  feature "selects option by clicking anywhere within complex markup", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the main title text within the option
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='urgent']"))
    |> execute_script(
      "const searchVal = document.querySelector('#flexible-markup-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "urgent",
               "Expected search input value to be 'urgent', got '#{values["search"]}'"

        assert values["submit"] == "urgent",
               "Expected submit input value to be 'urgent', got '#{values["submit"]}'"
      end
    )
  end

  feature "selects option by clicking on nested description text", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the high priority option
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='high']"))
    |> execute_script(
      "const searchVal = document.querySelector('#flexible-markup-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "high",
               "Expected search input value to be 'high', got '#{values["search"]}'"

        assert values["submit"] == "high",
               "Expected submit input value to be 'high', got '#{values["submit"]}'"
      end
    )
  end

  feature "selects option by clicking on SVG icon", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the SVG icon within the medium priority option
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='medium'] svg"))
    |> execute_script(
      "const searchVal = document.querySelector('#flexible-markup-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "medium",
               "Expected search input value to be 'medium', got '#{values["search"]}'"

        assert values["submit"] == "medium",
               "Expected submit input value to be 'medium', got '#{values["submit"]}'"
      end
    )
  end

  feature "selects option by clicking on the container div", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the option itself (testing that basic click still works)
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='low']"))
    |> execute_script(
      "const searchVal = document.querySelector('#flexible-markup-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "low",
               "Expected search input value to be 'low', got '#{values["search"]}'"

        assert values["submit"] == "low",
               "Expected submit input value to be 'low', got '#{values["submit"]}'"
      end
    )
  end

  feature "navigates complex markup options with keyboard arrows", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(5))
    # First option should be focused by default
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='urgent'][data-focus=true]")
    )
    # Arrow down to next option
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='high'][data-focus=true]")
    )
    # Arrow down again
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='medium'][data-focus=true]")
    )
    # Arrow up back to previous
    |> send_keys([:up_arrow])
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='high'][data-focus=true]")
    )
  end

  feature "selects focused complex markup option with Enter key", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Navigate to backlog option
    |> send_keys([:down_arrow, :down_arrow, :down_arrow, :down_arrow])
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='backlog'][data-focus=true]")
    )
    # Select with Enter
    |> send_keys([:enter])
    # Options should be hidden after selection
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the selected value
    |> execute_script(
      "const searchVal = document.querySelector('#flexible-markup-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "backlog",
               "Expected search input value to be 'backlog', got '#{values["search"]}'"

        assert values["submit"] == "backlog",
               "Expected submit input value to be 'backlog', got '#{values["submit"]}'"
      end
    )
  end

  feature "filters complex markup options based on search input", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@all_options |> Query.count(5))
    # Type "urg" - should show only urgent
    |> fill_in(@search_input, with: "urg")
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='urgent']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#flexible-markup-combobox [role=option][data-value='high']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#flexible-markup-combobox [role=option][data-value='medium']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#flexible-markup-combobox [role=option][data-value='low']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#flexible-markup-combobox [role=option][data-value='backlog']")
      |> Query.visible(true)
    )
  end

  feature "focuses complex markup option on mouse hover", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Hover over the medium option
    |> hover(Query.css("#flexible-markup-combobox [role=option][data-value='medium']"))
    |> assert_has(
      Query.css("#flexible-markup-combobox [role=option][data-value='medium'][data-focus=true]")
    )
  end

  feature "ensures form integration works with complex markup", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select the high priority option
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='high']"))
    # Verify the form input has the correct name and value for submission
    |> execute_script(
      "const input = document.querySelector('#flexible-markup-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {name: input ? input.name : '', value: input ? input.value : ''}",
      fn data ->
        assert data["name"] == "priority",
               "Expected form input name to be 'priority', got '#{data["name"]}'"

        assert data["value"] == "high",
               "Expected form input value to be 'high', got '#{data["value"]}'"
      end
    )
  end
end
