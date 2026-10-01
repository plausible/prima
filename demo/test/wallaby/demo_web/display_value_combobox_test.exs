defmodule DemoWeb.DisplayValueComboboxTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#country-combobox")
  @search_input Query.css("#country-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#country-combobox [data-prima-ref=options]")

  feature "selected label stays unchanged until the item is removed and selected again", %{
    session: session
  } do
    country = Query.css("#country-combobox [role=option][data-value='US']")

    session
    |> visit_fixture("/fixtures/display-value-combobox", "#country-combobox")
    |> click(@search_input)
    |> click(country)
    # Simulate refreshed option metadata without changing the committed selection.
    |> execute_script("""
    const option = document.querySelector('#country-combobox [data-value="US"]');
    option.dataset.display = 'USA';
    option.textContent = 'USA';
    """)
    |> fill_in(@search_input, with: "Germany")
    |> send_keys([:escape])
    |> assert_country_selection("United States", "US")
    |> click(Query.css("body"))
    |> click(@search_input)
    |> send_keys([:backspace])
    |> send_keys([:escape])
    |> assert_country_selection("", "")
    |> click(@search_input)
    |> click(country)
    |> fill_in(@search_input, with: "Germany")
    |> send_keys([:escape])
    |> assert_country_selection("USA", "US")
  end

  defp assert_country_selection(session, label, value) do
    execute_script(
      session,
      """
      const root = document.querySelector('#country-combobox');
      return {
        label: root.querySelector('[data-prima-ref=search_input]').value,
        value: root.querySelector('input[type=hidden]')?.value || ''
      };
      """,
      fn result -> assert result == %{"label" => label, "value" => value} end
    )
  end

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
    |> execute_script(
      "const searchVal = document.querySelector('#country-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#country-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "United States",
               "Expected search input to show display value 'United States', got '#{values["search"]}'"

        assert values["submit"] == "US",
               "Expected submit input to have code value 'US', got '#{values["submit"]}'"
      end
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
    |> execute_script(
      "const searchVal = document.querySelector('#country-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#country-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "Germany",
               "Expected search input to show display value 'Germany', got '#{values["search"]}'"

        assert values["submit"] == "DE",
               "Expected submit input to have code value 'DE', got '#{values["submit"]}'"
      end
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
    |> execute_script(
      "const searchVal = document.querySelector('#country-combobox input[data-prima-ref=search_input]').value; const hiddenInput = document.querySelector('#country-combobox [data-prima-ref=submit_container] input[type=hidden]'); return {search: searchVal, submit: hiddenInput ? hiddenInput.value : ''}",
      fn values ->
        assert values["search"] == "United Kingdom",
               "Expected search input to show 'United Kingdom', got '#{values["search"]}'"

        assert values["submit"] == "GB",
               "Expected submit input to have 'GB', got '#{values["submit"]}'"
      end
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
