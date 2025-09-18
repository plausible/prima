defmodule PrimaWeb.CreatableComboboxTest do
  use Prima.WallabyCase, async: true

  @combobox_container Query.css("#demo-creatable-combobox")
  @search_input Query.css("#demo-creatable-combobox input[data-prima-ref=search_input]")
  @options_container Query.css("#demo-creatable-combobox [data-prima-ref=options]")
  @create_option Query.css("#demo-creatable-combobox [data-prima-ref=create-option]")
  @regular_options Query.css(
                     "#demo-creatable-combobox [role=option]:not([data-prima-ref=create-option])"
                   )

  feature "create option is hidden initially when combobox opens", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> assert_has(@combobox_container)
    |> assert_has(@search_input)
    |> assert_has(@options_container |> Query.visible(false))
    # Focus the input to open options
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(@regular_options |> Query.count(4))
    # Create option should be hidden initially since search input is empty
    |> assert_missing(@create_option |> Query.visible(true))
  end

  feature "create option appears when typing non-matching text", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something that doesn't match existing options
    |> fill_in(@search_input, with: "Grape")
    # Create option should now be visible
    |> assert_has(@create_option |> Query.visible(true))
    # Verify create option has correct content
    |> assert_has(@create_option |> Query.text("Create \"Grape\""))
  end

  feature "create option is hidden when typing exact match", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type something that exactly matches an existing option
    |> fill_in(@search_input, with: "Apple")
    # Create option should be hidden because of exact match
    |> assert_missing(@create_option |> Query.visible(true))
    # Regular Apple option should be visible
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
  end

  feature "create option is hidden when typing partial match if exact match exists", %{
    session: session
  } do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> assert_has(@options_container |> Query.visible(true))
    # Type partial match that also has an exact match
    |> fill_in(@search_input, with: "app")
    # Create option should be visible since "app" doesn't exactly match any option
    |> assert_has(@create_option |> Query.visible(true))
    |> assert_has(@create_option |> Query.text("Create \"app\""))
    # Apple and Pineapple should be visible (contain "app")
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Pineapple']")
      |> Query.visible(true)
    )
  end

  feature "create option updates text dynamically as user types", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "Gr")
    |> assert_has(@create_option |> Query.visible(true))
    |> assert_has(@create_option |> Query.text("Create \"Gr\""))
    # Continue typing
    |> fill_in(@search_input, with: "Grape")
    |> assert_has(@create_option |> Query.text("Create \"Grape\""))
    # Type more
    |> fill_in(@search_input, with: "Grapefruit")
    |> assert_has(@create_option |> Query.text("Create \"Grapefruit\""))
  end

  feature "selecting create option sets both search and submit inputs", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "Strawberry")
    |> assert_has(@create_option |> Query.visible(true))
    |> assert_has(@create_option |> Query.text("Create \"Strawberry\""))
    # Click the create option
    |> click(@create_option)
    # Options should be hidden after selection
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the created value
    |> execute_script(
      "return {search: document.querySelector('#demo-creatable-combobox input[data-prima-ref=search_input]').value, submit: document.querySelector('#demo-creatable-combobox input[data-prima-ref=submit_input]').value}",
      fn values ->
        assert values["search"] == "Strawberry",
               "Expected search input value to be 'Strawberry', got '#{values["search"]}'"

        assert values["submit"] == "Strawberry",
               "Expected submit input value to be 'Strawberry', got '#{values["submit"]}'"
      end
    )
  end

  feature "selecting create option with keyboard navigation", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "Watermelon")
    |> assert_has(@create_option |> Query.visible(true))
    # Click the create option directly for now (keyboard navigation test can be separate)
    |> click(@create_option)
    # Options should be hidden after selection
    |> assert_has(@options_container |> Query.visible(false))
    # Check that both inputs have the created value
    |> execute_script(
      "return {search: document.querySelector('#demo-creatable-combobox input[data-prima-ref=search_input]').value, submit: document.querySelector('#demo-creatable-combobox input[data-prima-ref=submit_input]').value}",
      fn values ->
        assert values["search"] == "Watermelon",
               "Expected search input value to be 'Watermelon', got '#{values["search"]}'"

        assert values["submit"] == "Watermelon",
               "Expected submit input value to be 'Watermelon', got '#{values["submit"]}'"
      end
    )
  end

  feature "keyboard navigation skips hidden create option when exact match exists", %{
    session: session
  } do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "Apple")
    # Create option should be hidden because of exact match
    |> assert_missing(@create_option |> Query.visible(true))
    # Focus should be on Apple option initially
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple'][data-focus=true]")
    )
    # Arrow down should go to Pineapple (next visible option that contains "apple"), not the hidden create option
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Pineapple'][data-focus=true]")
    )
    # Arrow down from last visible option should wrap to first visible option (Apple), not create option
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple'][data-focus=true]")
    )
  end

  feature "keyboard navigation includes create option when visible", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "Grape")
    # Create option should be visible
    |> assert_has(@create_option |> Query.visible(true))
    # Focus should be on create option since it's the only visible option
    |> assert_has(
      Query.css("#demo-creatable-combobox [data-prima-ref=create-option][data-focus=true]")
    )
    # Arrow down should cycle back to create option (only visible option)
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#demo-creatable-combobox [data-prima-ref=create-option][data-focus=true]")
    )
  end

  feature "focus handling when create option disappears during navigation", %{session: session} do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "Grape")
    # Create option should be visible and focused
    |> assert_has(@create_option |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-creatable-combobox [data-prima-ref=create-option][data-focus=true]")
    )
    # Type "fruit" to change search to "Grapefruit" - create option should still be visible
    |> send_keys("fruit")
    |> assert_has(@create_option |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-creatable-combobox [data-prima-ref=create-option][data-focus=true]")
    )
    # Now clear and type "Apple" - create option should disappear due to exact match
    |> fill_in(@search_input, with: "Apple")
    # Create option should be hidden
    |> assert_missing(@create_option |> Query.visible(true))
    # Focus should move to Apple option (first visible option)
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple'][data-focus=true]")
    )
  end

  feature "focus handling when clearing input after filtering to create option only", %{
    session: session
  } do
    session
    |> visit("/fixtures/creatable-combobox")
    |> click(@search_input)
    |> fill_in(@search_input, with: "z")
    # Only create option should be visible
    |> assert_has(@create_option |> Query.visible(true))
    |> assert_has(
      Query.css("#demo-creatable-combobox [data-prima-ref=create-option][data-focus=true]")
    )
    # All regular options should be hidden
    |> assert_missing(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-creatable-combobox [role=option][data-value='Pear']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-creatable-combobox [role=option][data-value='Mango']")
      |> Query.visible(true)
    )
    |> assert_missing(
      Query.css("#demo-creatable-combobox [role=option][data-value='Pineapple']")
      |> Query.visible(true)
    )
    # Clear the input
    |> fill_in(@search_input, with: "")
    # Manually trigger input event since Wallaby doesn't trigger it for empty values
    |> execute_script(
      "document.querySelector('#demo-creatable-combobox input[data-prima-ref=search_input]').dispatchEvent(new Event('input', {bubbles: true}))"
    )
    # Create option should be hidden (empty input)
    |> assert_missing(@create_option |> Query.visible(true))
    # All regular options should be visible again
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Pear']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Mango']")
      |> Query.visible(true)
    )
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Pineapple']")
      |> Query.visible(true)
    )
    # First visible option (Apple) should be focused
    |> assert_has(
      Query.css("#demo-creatable-combobox [role=option][data-value='Apple'][data-focus=true]")
    )
  end
end
