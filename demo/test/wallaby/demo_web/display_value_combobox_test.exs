defmodule DemoWeb.DisplayValueComboboxTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#country-combobox")
  @search_input Query.css("#country-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#country-combobox [data-prima-ref=options]")

  feature "displays country name in search input after selecting country code", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/display-value-combobox", "#country-combobox")
    |> assert_has(@combobox_container)
    |> assert_has(@search_input)
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click to select United States (code: US)
    |> click(Query.css("#country-combobox [role=option][data-value='US']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the search input shows the display name "United States" not the code "US"
    |> assert_combobox_selection(
      "#country-combobox",
      "country-combobox[country]",
      "United States",
      "US"
    )
  end

  feature "displays correct country name after selecting Germany", %{session: session} do
    session
    |> visit_fixture("/fixtures/display-value-combobox", "#country-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click to select Germany (code: DE)
    |> click(Query.css("#country-combobox [role=option][data-value='DE']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the search input shows "Germany" not "DE"
    |> assert_combobox_selection(
      "#country-combobox",
      "country-combobox[country]",
      "Germany",
      "DE"
    )
  end

  feature "filters by display name but submits country code", %{session: session} do
    session
    |> visit_fixture("/fixtures/display-value-combobox", "#country-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type "united" to filter - should show United States and United Kingdom
    |> fill_in(@search_input, with: "united")
    |> assert_has(
      Query.css("#country-combobox [role=option][data-value='US']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#country-combobox [role=option][data-value='GB']")
      |> Query.visible(true)
    )
    # Other countries should not be visible
    |> assert_missing(
      Query.css("#country-combobox [role=option][data-value='CA']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#country-combobox [role=option][data-value='AU']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#country-combobox [role=option][data-value='DE']")
      |> Query.visible(true)
    )
    # Select United Kingdom
    |> click(Query.css("#country-combobox [role=option][data-value='GB']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify correct values
    |> assert_combobox_selection(
      "#country-combobox",
      "country-combobox[country]",
      "United Kingdom",
      "GB"
    )
  end

  feature "display name persists in search input after reopening", %{session: session} do
    session
    |> visit_fixture("/fixtures/display-value-combobox", "#country-combobox")
    |> click(@search_input)
    |> click(Query.css("#country-combobox [role=option][data-value='CA']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Re-open the combobox
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Search input should still show "Canada" not "CA"
    |> execute_script(
      "return document.querySelector('#country-combobox input[data-prima-ref=search_input]').value",
      fn value ->
        assert value == "Canada",
               "Expected search input to show 'Canada' after reopening, got '#{value}'"
      end
    )
  end
end
