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
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "urgent", "urgent")
  end

  feature "selects option by clicking on nested description text", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the high priority option
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='high']"))
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "high", "high")
  end

  feature "selects option by clicking on SVG icon", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the SVG icon within the medium priority option
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='medium'] svg"))
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "medium", "medium")
  end

  feature "selects option by clicking on the container div", %{session: session} do
    session
    |> visit_fixture("/fixtures/flexible-markup-combobox", "#flexible-markup-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click on the option itself (testing that basic click still works)
    |> click(Query.css("#flexible-markup-combobox [role=option][data-value='low']"))
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "low", "low")
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
    |> assert_combobox_selection("#flexible-markup-combobox", "priority", "backlog", "backlog")
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
    |> execute_script(
      """
      const form = document.querySelector('#flexible-markup-combobox').closest('form');
      return Array.from(new FormData(form).entries());
      """,
      fn entries -> assert entries == [["priority", "high"]] end
    )
  end
end
