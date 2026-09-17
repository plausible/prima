defmodule DemoWeb.DropdownMultilineItemsTest do
  use Prima.WallabyCase, async: true

  @dropdown_button Query.css("#dropdown-multiline [aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown-multiline [role=menu]")

  feature "mouse hover tracks the cursor when items have multiple child elements", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-multiline-items", "#dropdown-multiline")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Hovering over a child element inside the first item (not the item itself)
    # should still focus the item.
    |> execute_script(
      "document.querySelector('#dropdown-multiline-item-0 div:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#dropdown-multiline-item-0[data-focus]"))
    # Hovering over a child element inside the second item should move focus
    # there and clear it from the first item.
    |> execute_script(
      "document.querySelector('#dropdown-multiline-item-1 div:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#dropdown-multiline-item-1[data-focus]"))
    |> assert_missing(Query.css("#dropdown-multiline-item-0[data-focus]"))
  end

  feature "clicking a child element inside an item closes the menu and refocuses the trigger",
          %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-multiline-items", "#dropdown-multiline")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Click lands on the child div, not the [role=menuitem] element itself.
    |> click(Query.css("#dropdown-multiline-item-1 div:last-child"))
    |> assert_has(@dropdown_menu |> Query.visible(false))
    |> assert_has(Query.css("#dropdown-multiline-trigger:focus"))
  end
end
