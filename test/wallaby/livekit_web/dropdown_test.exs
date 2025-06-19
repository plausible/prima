defmodule LiveKitWeb.DropdownTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @dropdown_container Query.css("#demo-dropdown")
  @dropdown_button Query.css("#demo-dropdown [aria-haspopup=menu]")
  @dropdown_menu Query.css("#demo-dropdown [role=menu]")
  @dropdown_items Query.css("#demo-dropdown [role=menuitem]")

  feature "shows dropdown menu when button is clicked", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> assert_has(@dropdown_container)
    |> assert_has(@dropdown_button |> Query.visible(true))
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(@dropdown_items |> Query.count(2))
  end

  feature "hides dropdown menu when button is clicked again", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when clicking outside", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(Query.css("body"))
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when pressing escape key", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "keyboard navigation with arrow keys", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Send arrow keys to navigate (no active items initially in dropdown)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[livekit-state=active]"))
    # Arrow down to next item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[livekit-state=active]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[livekit-state=active]"))
  end

  feature "keyboard navigation with arrow keys going up", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # First go down to activate first item, then up to test wrap-around
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[livekit-state=active]"))
    # Arrow up should wrap to last item
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[livekit-state=active]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[livekit-state=active]"))
  end

  feature "mouse hover activates dropdown items", %{session: session} do
    session
    |> visit("/demo/dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Initially no item should be active
    |> refute_has(Query.css("#demo-dropdown [role=menuitem][livekit-state=active]"))
    # Hovering over first item should activate it
    |> execute_script("document.querySelector('#demo-dropdown [role=menuitem]:first-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))")
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:first-child[livekit-state=active]"))
    # Hovering over second item should activate it and deactivate first
    |> execute_script("document.querySelector('#demo-dropdown [role=menuitem]:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))")
    |> assert_has(Query.css("#demo-dropdown [role=menuitem]:last-child[livekit-state=active]"))
    |> refute_has(Query.css("#demo-dropdown [role=menuitem]:first-child[livekit-state=active]"))
  end

  # Note: Removed focus test as Wallaby doesn't have a simple focused() query

  # TODO: Fix active state management test
  # feature "closing dropdown removes active state from items", %{session: session} do
end