defmodule DemoWeb.DropdownTest do
  use Prima.WallabyCase, async: true

  @dropdown_container Query.css("#dropdown")
  @dropdown_button Query.css("#dropdown [aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown [role=menu]")
  @dropdown_items Query.css("#dropdown [role=menuitem]")

  feature "default dropdown trigger has type='button'", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(Query.css("#dropdown button[aria-haspopup=menu][type=button]"))
  end

  feature "shows dropdown menu when button is clicked", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(@dropdown_container)
    |> assert_has(@dropdown_button |> Query.visible(true))
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(@dropdown_items |> Query.count(4))
  end

  feature "hides dropdown menu when button is clicked again", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when clicking outside", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(Query.css("#outside-area"))
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when pressing escape key", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "keyboard navigation with arrow keys", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Send arrow keys to navigate (no active items initially in dropdown)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Arrow down to next item (now we have 4 items, so need 3 more downs to reach last)
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "mouse hover activates dropdown items", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
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
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
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
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
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
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
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
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
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
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu]"))
    |> click(@dropdown_button)
    |> assert_has(Query.css("#dropdown [role=menu]"))
    |> assert_has(Query.css("#dropdown [role=menuitem]") |> Query.count(4))
  end

  feature "aria-expanded reflects dropdown state", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    # Initially dropdown should be collapsed
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu][aria-expanded=false]"))
    # After clicking, dropdown should be expanded
    |> click(@dropdown_button)
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu][aria-expanded=true]"))
    # After closing, dropdown should be collapsed again
    |> click(@dropdown_button)
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu][aria-expanded=false]"))
  end

  feature "auto-generates IDs and aria-controls relationship", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    # Trigger button should have auto-generated ID and aria-controls
    |> assert_has(
      Query.css(
        "#dropdown [aria-haspopup=menu][id='dropdown-trigger'][aria-controls='dropdown-menu']"
      )
    )
    # Menu should have matching ID referenced by aria-controls (check with visible false since menu is initially hidden)
    |> assert_has(Query.css("#dropdown [role=menu][id='dropdown-menu']") |> Query.visible(false))
    # Menu should reference trigger via aria-labelledby
    |> assert_has(
      Query.css("#dropdown [role=menu][aria-labelledby='dropdown-trigger']")
      |> Query.visible(false)
    )
  end

  feature "auto-generates menuitem IDs and manages aria-activedescendant", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    # Each menuitem should have auto-generated ID
    |> assert_has(Query.css("#dropdown [role=menuitem][id='dropdown-item-0']"))
    |> assert_has(Query.css("#dropdown [role=menuitem][id='dropdown-item-1']"))
    # Initially no aria-activedescendant
    |> assert_has(Query.css("#dropdown [role=menu]:not([aria-activedescendant])"))
    # After keyboard navigation, aria-activedescendant should point to focused item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menu][aria-activedescendant='dropdown-item-0']"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menu][aria-activedescendant='dropdown-item-1']"))
  end

  feature "dropdown remains functional after LiveView reconnection", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> execute_script("window.liveSocket.disconnect()")
    |> execute_script("window.liveSocket.connect()")
    # Wait for reconnection by checking for the data attribute that gets set
    |> assert_has(Query.css(".phx-connected[data-phx-main]"))
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "closes dropdown when clicking on a menuitem", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(Query.css("#dropdown [role=menuitem]:first-child"))
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "opens dropdown and focuses first item when Enter is pressed on button", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> execute_script("document.querySelector('#dropdown [aria-haspopup=menu]').focus()")
    |> send_keys([:enter])
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "opens dropdown and focuses first item when Space is pressed on button", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> execute_script("document.querySelector('#dropdown [aria-haspopup=menu]').focus()")
    |> send_keys([" "])
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "opens dropdown and focuses first item when ArrowDown is pressed on button", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> execute_script("document.querySelector('#dropdown [aria-haspopup=menu]').focus()")
    |> send_keys([:down_arrow])
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "opens dropdown and focuses last item when ArrowUp is pressed on button", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> execute_script("document.querySelector('#dropdown [aria-haspopup=menu]').focus()")
    |> send_keys([:up_arrow])
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
  end

  feature "focuses first item when Home is pressed in open menu", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # First navigate to last item (4 items total)
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    # Now press Home to go to first item
    |> send_keys([:home])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
  end

  feature "focuses last item when End is pressed in open menu", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # First navigate to first item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Now press End to go to last item
    |> send_keys([:end])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "focuses first item when PageUp is pressed in open menu", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # First navigate to last item (4 items total)
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    # Now press PageUp to go to first item
    |> send_keys([:pageup])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
  end

  feature "focuses last item when PageDown is pressed in open menu", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # First navigate to first item
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    # Now press PageDown to go to last item
    |> send_keys([:pagedown])
    |> assert_has(Query.css("#dropdown [role=menuitem]:last-child[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "typeahead search focuses matching item", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Type "a" to focus on the first item that starts with "a" (Apple)
    |> send_keys(["a"])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
  end

  feature "typeahead search with different letters", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Type "b" to focus on Banana (2nd item)
    |> send_keys(["b"])
    |> assert_has(Query.css("#dropdown [role=menuitem]:nth-child(2)[data-focus]"))
    # Type "c" to focus on Cherry (3rd item)
    |> send_keys(["c"])
    |> assert_has(Query.css("#dropdown [role=menuitem]:nth-child(3)[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:nth-child(2)[data-focus]"))
  end

  feature "typeahead search cycles through matching items with repeated presses", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown", "#dropdown")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Type "a" to focus on Apple (1st item)
    |> send_keys(["a"])
    |> assert_has(Query.css("#dropdown [role=menuitem]:nth-child(1)[data-focus]"))
    # Type "a" again to cycle to Apricot (4th item)
    |> send_keys(["a"])
    |> assert_has(Query.css("#dropdown [role=menuitem]:nth-child(4)[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:nth-child(1)[data-focus]"))
    # Type "a" again to cycle back to Apple (1st item)
    |> send_keys(["a"])
    |> assert_has(Query.css("#dropdown [role=menuitem]:nth-child(1)[data-focus]"))
    |> assert_missing(Query.css("#dropdown [role=menuitem]:nth-child(4)[data-focus]"))
  end
end
