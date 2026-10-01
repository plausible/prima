defmodule DemoWeb.ComboboxFormIntegrationTest do
  use Prima.WallabyCase, async: true

  @combobox Query.css("#change-combobox")
  @search_input Query.css("#change-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#change-options")
  @selection_display Query.css("#selection-display")
  @async_root "#async-form-change-combobox"
  @async_input Query.css("#{@async_root} [data-prima-ref=search_input]")
  @async_options Query.css("#{@async_root} [role=option]")

  feature "async demo opens with default options before typing", %{session: session} do
    session
    |> visit_fixture("/combobox", "#demo-async-combobox")
    |> click(Query.css("#demo-async-combobox [data-prima-ref=search_input]"))
    |> assert_has(Query.css("#demo-async-combobox [role=option]", count: 5))
  end

  feature "async dismissal restores default results after clicking outside", %{session: session} do
    assert_async_reopens(session, :outside)
  end

  feature "async dismissal restores default results after Escape", %{session: session} do
    assert_async_reopens(session, :escape)
  end

  feature "dismissing a pending debounce sends the empty query without changing selection", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox-form-change?slow_debounce=true", @async_root)
    |> click(@async_input)
    |> assert_has(@async_options |> Query.count(5))
    |> click(Query.css("#{@async_root} [data-value=Cherry]"))
    |> assert_form_change_count(@async_root, 1)
    |> execute_script("""
    const root = document.querySelector('#async-form-change-combobox');
    const input = root.querySelector('[data-prima-ref=search_input]');
    input.value = 'Ki';
    input.dispatchEvent(new Event('input', {bubbles: true}));
    document.body.click();
    input.click();
    """)
    |> assert_has(@async_options |> Query.count(5))
    |> assert_async_fields()
    |> assert_form_change_count(@async_root, 1)
    |> execute_script(
      "return JSON.parse(document.querySelector('#search-history').dataset.queries)",
      fn queries ->
        refute "Ki" in queries
        assert List.last(queries) == ""
      end
    )
  end

  feature "reopening receives default results after a delayed reply", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox-form-change", @async_root)
    |> click(@async_input)
    |> assert_has(@async_options |> Query.count(5))
    |> click(Query.css("#{@async_root} [data-value=Cherry]"))
    |> fill_in(@async_input, with: "Ki")
    |> assert_has(Query.css("#{@async_root} [data-value=Kiwi]"))
    |> assert_has(@async_options |> Query.count(1))
    |> execute_script("window.liveSocket.enableLatencySim(200)")
    |> click(Query.css("body"))
    |> assert_has(Query.css("#async-form-change-options", visible: false))
    |> click(@async_input)
    |> assert_has(Query.css("#{@async_root}.phx-hook-loading"))
    |> assert_has(@async_options |> Query.count(5))
    |> assert_async_fields()
    |> assert_form_change_count(@async_root, 1)
  end

  feature "async demo supports LiveComponent search and selection without a form", %{
    session: session
  } do
    session
    |> visit_fixture("/combobox", "#demo-async-combobox")
    |> click(Query.css("#demo-async-combobox [data-prima-ref=search_input]"))
    |> execute_script("window.liveSocket.enableLatencySim(200)")
    |> fill_in(Query.css("#demo-async-combobox [data-prima-ref=search_input]"), with: "Ki")
    |> assert_has(Query.css("#demo-async-combobox .search-spinner"))
    |> assert_has(Query.css("#demo-async-combobox [role=option]", count: 1, text: "Kiwi"))
    |> assert_has(Query.css("#demo-async-combobox .search-spinner", visible: false))
    |> click(Query.css("#demo-async-combobox [data-value=Kiwi]"))
    |> execute_script(
      """
      const root = document.querySelector('#demo-async-combobox');
      const selection = root.querySelector('[data-prima-ref=submit_container] input');
      return {name: selection.name, value: selection.value};
      """,
      fn result ->
        assert result == %{"name" => "user[favourite_fruit]", "value" => "Kiwi"}
      end
    )
  end

  defp assert_async_reopens(session, dismissal) do
    session =
      session
      |> visit_fixture("/fixtures/async-combobox-form-change", @async_root)
      |> click(@async_input)
      |> assert_has(@async_options |> Query.count(5))
      |> click(Query.css("#{@async_root} [data-value=Cherry]"))
      |> click(@async_input)
      |> assert_has(@async_options |> Query.count(5))
      |> fill_in(@async_input, with: "Ki")
      |> assert_has(Query.css("#{@async_root} [data-value=Kiwi]"))
      |> assert_has(@async_options |> Query.count(1))

    session =
      case dismissal do
        :outside -> click(session, Query.css("body"))
        :escape -> send_keys(session, [:escape])
      end

    session
    |> assert_has(Query.css("#async-form-change-options", visible: false))
    |> click(@async_input)
    |> assert_has(@async_options |> Query.count(5))
    |> assert_async_fields()
    |> assert_form_change_count(@async_root, 1)
  end

  defp assert_async_fields(session) do
    execute_script(
      session,
      """
      const root = document.querySelector('#async-form-change-combobox');
      const form = new FormData(root.closest('form'));
      return {display: root.querySelector('[data-prima-ref=search_input]').value,
        selection: form.get('fruit'), query: form.get('fruit_search')};
      """,
      fn result ->
        assert result == %{"display" => "Cherry", "selection" => "Cherry", "query" => nil}
      end
    )
  end

  defp assert_form_change_count(session, combobox_id, expected_count) do
    session
    |> assert_missing(Query.css("#{combobox_id} .phx-change-loading", visible: :any))
    |> assert_has(Query.css("#change-count", text: "Form changes: #{expected_count}"))
  end

  feature "phx-change on combobox fires when user selects an option", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    |> assert_has(@combobox)
    # Initially, no selection
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Click to open options
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Select Apple
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the selection display was updated via phx-change event
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
  end

  feature "phx-change on combobox fires when user changes selection", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Select Apple first
    |> click(@search_input)
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    # Now select Mango
    |> click(@search_input)
    |> click(Query.css("#change-combobox [role=option][data-value='Mango']"))
    # Verify the selection display was updated to Mango
    |> assert_has(@selection_display |> Query.text("Selected: Mango"))
  end

  feature "phx-change on combobox fires when selection is made via keyboard", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Open options and use keyboard to select
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Press Enter to select the first (focused) option
    |> send_keys([:enter])
    |> assert_has(@options_container |> Query.visible(false))
    # Verify the selection display was updated
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
  end

  feature "phx-change on combobox does not fire when clicking outside without selection", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    |> assert_has(@selection_display |> Query.text("Selected: none"))
    # Open options
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Click outside without selecting
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
    # Selection display should still show "none"
    |> assert_has(@selection_display |> Query.text("Selected: none"))
  end

  feature "phx-change on parent form fires only on selection, not on search input", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Type in search input - should NOT trigger form phx-change
    |> click(Query.css("#change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"), with: "a")
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"), with: "app")
    |> assert_form_change_count("#change-combobox", 0)
    # Now select an option - this SHOULD trigger form phx-change
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_form_change_count("#change-combobox", 1)
    # Type in search again to filter options
    |> click(Query.css("#change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"),
      with: "Pear"
    )
    |> assert_form_change_count("#change-combobox", 1)
    # Now change selection - should increment count to 2
    |> click(Query.css("#change-combobox [role=option][data-value='Pear']"))
    |> assert_form_change_count("#change-combobox", 2)
  end

  feature "search input value persists after selection when form phx-change triggers update", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Type in search input and select an option
    |> click(Query.css("#change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#change-combobox input[data-prima-ref=search_input]"), with: "app")
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_form_change_count("#change-combobox", 1)
    # Verify the search input still shows the display value "Apple"
    |> then(fn session ->
      input_value =
        session
        |> find(Query.css("#change-combobox input[data-prima-ref=search_input]"))
        |> Element.value()

      assert input_value == "Apple",
             "Expected search input value to be 'Apple' but got '#{input_value}'"

      session
    end)
  end

  feature "async combobox: form phx-change fires only on selection, not on search", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/async-combobox-form-change", "#async-form-change-combobox")
    # Type in search input - should trigger async search but NOT form phx-change
    |> click(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"),
      with: "an"
    )
    # Wait for async search to complete and show options
    |> assert_has(Query.css("#async-form-change-options") |> Query.visible(true))
    |> assert_has(Query.css("#async-form-change-combobox [role=option][data-value='Orange']"))
    |> assert_form_change_count("#async-form-change-combobox", 0)
    # Now select an option - this SHOULD trigger form phx-change
    |> click(Query.css("#async-form-change-combobox [role=option][data-value='Orange']"))
    |> assert_form_change_count("#async-form-change-combobox", 1)
    # Type again to search - should NOT increment count
    |> click(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"))
    |> fill_in(Query.css("#async-form-change-combobox input[data-prima-ref=search_input]"),
      with: "Ba"
    )
    |> assert_has(Query.css("#async-form-change-combobox [role=option][data-value='Banana']"))
    |> assert_form_change_count("#async-form-change-combobox", 1)
    # Change selection - should increment count to 2
    |> click(Query.css("#async-form-change-combobox [role=option][data-value='Banana']"))
    |> assert_form_change_count("#async-form-change-combobox", 2)
  end

  feature "phx-change fires when clearing selection via backspace", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-change", "#change-combobox")
    # Select Apple first
    |> click(@search_input)
    |> click(Query.css("#change-combobox [role=option][data-value='Apple']"))
    |> assert_has(@selection_display |> Query.text("Selected: Apple"))
    |> assert_form_change_count("#change-combobox", 1)
    # Click outside to blur
    |> click(Query.css("body"))
    # Click back in and hit backspace to clear
    |> click(@search_input)
    |> send_keys([:backspace])
    # Should trigger phx-change with cleared value
    |> assert_form_change_count("#change-combobox", 2)
    |> assert_has(@selection_display |> Query.text("Selected: none"))
  end
end
