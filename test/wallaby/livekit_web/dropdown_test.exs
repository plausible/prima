defmodule LiveKitWeb.DropdownTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @dropdown_container Query.css("#demo-dropdown")
  @dropdown_button Query.css("#demo-dropdown [aria-haspopup=menu]")
  @dropdown_menu Query.css("#demo-dropdown [role=menu]")
  @dropdown_items Query.css("#demo-dropdown [role=menuitem]")

  feature "shows dropdown menu when button is clicked", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> assert_has(@dropdown_container)
    |> assert_has(@dropdown_button |> Query.visible(true))
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(@dropdown_items |> Query.count(2))
  end

  feature "hides dropdown menu when button is clicked again", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when clicking outside", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(Query.css("body"))
    # Check if element exists at all (regardless of visibility)
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when pressing escape key", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "keyboard navigation with arrow keys", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Send arrow keys to navigate (no active items initially in dropdown)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow down to next item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[data-focus]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "mouse hover activates dropdown items", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Initially no item should be active
    |> refute_has(Query.css("#demo-dropdown [role=menuitem][data-focus]"))
    # Hovering over first item should activate it
    |> execute_script(
      "document.querySelector('#demo-dropdown [role=menuitem]:first-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    # Hovering over second item should activate it and deactivate first
    |> execute_script(
      "document.querySelector('#demo-dropdown [role=menuitem]:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[data-focus]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "focus state behavior when reopening dropdown", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Activate an item with arrow key
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    # Close dropdown with escape key
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Reopen dropdown by clicking button
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Check that focus state is cleared - the first item should not have data-focus attribute
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "keyboard navigation wraps around (last to first, first to last)", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Navigate down to first item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow up from first should wrap to last item
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[data-focus]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow down from last should wrap to first item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:last-child[data-focus]"))
  end

  feature "hover deactivates keyboard-activated items", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Activate first item with keyboard
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
    # Hover over second item should activate it and deactivate first
    |> execute_script(
      "document.querySelector('#demo-dropdown [role=menuitem]:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[data-focus]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "focus returns to trigger button when dropdown closes", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Close with escape
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Verify focus is on trigger button (we can test this by sending a key that would open the dropdown)
    |> send_keys([:enter])
    |> assert_has(@dropdown_menu |> Query.visible(true))
  end

  feature "supports accessible role and aria attributes", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> assert_has(Query.css("#demo-dropdown [aria-haspopup=menu]"))
    |> click(@dropdown_button)
    |> assert_has(Query.css("#demo-dropdown [role=menu]"))
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]") |> Query.count(2))
  end

  feature "dropdown menu initially has no active items", %{session: session} do
    session
    |> visit("/test/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Initially no items should have focus state
    |> refute_has(Query.css("#demo-dropdown [role=menuitem][data-focus]"))
  end
end
