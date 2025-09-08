defmodule LiveKitWeb.DropdownTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @dropdown_container Query.css("#dropdown")
  @dropdown_button Query.css("#dropdown [aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown [role=menu]")
  @dropdown_items Query.css("#dropdown [role=menuitem]")

  def assert_missing(session, query) do
    assert_has(session, query |> Query.count(0))
  end

  feature "shows dropdown menu when button is clicked", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> assert_has(@dropdown_container)
    |> assert_has(@dropdown_button |> Query.visible(true))
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(@dropdown_items |> Query.count(2))
  end

  feature "hides dropdown menu when button is clicked again", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when clicking outside", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(Query.css("#outside-area"))
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when pressing escape key", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "keyboard navigation with arrow keys", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Send arrow keys to navigate (no active items initially in dropdown)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow down to next item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "mouse hover activates dropdown items", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Initially no item should be active
    |> assert_has(Query.css("#dropdown [role=menuitem][data-focus]", count: 0))
    # Hovering over first item should activate it
    |> execute_script(
      "document.querySelector('#dropdown [role=menuitem]:first-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Hovering over second item should activate it and deactivate first
    |> execute_script(
      "document.querySelector('#dropdown [role=menuitem]:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]", count: 0))
  end

  feature "focus state behavior when reopening dropdown", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Activate an item with arrow key
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Close dropdown with escape key
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Reopen dropdown by clicking button
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Check that focus state is cleared - the first item should not have data-focus attribute
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "keyboard navigation wraps around (last to first, first to last)", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Navigate down to first item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow up from first should wrap to last item
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow down from last should wrap to first item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
  end

  feature "hover deactivates keyboard-activated items", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Activate first item with keyboard
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Hover over second item should activate it and deactivate first
    |> execute_script(
      "document.querySelector('#dropdown [role=menuitem]:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "focus returns to trigger button when dropdown closes", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Verify focus is on trigger button (we can test this by sending a key that would open the dropdown)
    |> send_keys([:enter])
    |> assert_has(@dropdown_menu |> Query.visible(true))
  end

  feature "supports accessible role and aria attributes", %{session: session} do
    session
    |> visit("/fixtures/dropdown")
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu]"))
    |> click(@dropdown_button)
    |> assert_has(Query.css("#dropdown [role=menu]"))
    |> assert_has(Query.css("#dropdown [role=menuitem]") |> Query.count(2))
  end
end
