defmodule PrimaWeb.DropdownDisabledTest do
  use Prima.WallabyCase, async: true

  @dropdown_container Query.css("#dropdown-with-disabled")
  @dropdown_button Query.css("#dropdown-with-disabled [aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown-with-disabled [role=menu]")
  @enabled_items Query.css("#dropdown-with-disabled [role=menuitem]:not([aria-disabled])")
  @disabled_item Query.css("#dropdown-with-disabled [role=menuitem][aria-disabled=true]")

  feature "disabled items have proper aria attributes", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-with-disabled", "#dropdown-with-disabled")
    |> assert_has(@dropdown_container)
    |> assert_has(
      Query.css("#dropdown-with-disabled [role=menuitem]")
      |> Query.count(3)
      |> Query.visible(false)
    )
    |> assert_has(@disabled_item |> Query.visible(false))
    |> assert_has(
      Query.css("#dropdown-with-disabled [role=menuitem][aria-disabled=true][data-disabled=true]")
      |> Query.visible(false)
    )
    |> assert_has(@enabled_items |> Query.count(2) |> Query.visible(false))
  end

  feature "keyboard navigation skips disabled items", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-with-disabled", "#dropdown-with-disabled")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Navigate down should go to first enabled item (skipping disabled)
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css(
        "#dropdown-with-disabled [role=menuitem]:not([aria-disabled]):first-of-type[data-focus]"
      )
    )
    |> assert_missing(
      Query.css("#dropdown-with-disabled [role=menuitem][aria-disabled=true][data-focus]")
    )
    # Navigate down again should go to last enabled item (skipping disabled)
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css(
        "#dropdown-with-disabled [role=menuitem]:not([aria-disabled]):last-of-type[data-focus]"
      )
    )
    |> assert_missing(
      Query.css(
        "#dropdown-with-disabled [role=menuitem]:not([aria-disabled]):first-of-type[data-focus]"
      )
    )
    |> assert_missing(
      Query.css("#dropdown-with-disabled [role=menuitem][aria-disabled=true][data-focus]")
    )
  end

  feature "keyboard navigation wraps around disabled items", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-with-disabled", "#dropdown-with-disabled")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Navigate to first enabled item
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css(
        "#dropdown-with-disabled [role=menuitem]:not([aria-disabled]):first-of-type[data-focus]"
      )
    )
    # Navigate up should wrap to last enabled item (skipping disabled)
    |> send_keys([:up_arrow])
    |> assert_has(
      Query.css(
        "#dropdown-with-disabled [role=menuitem]:not([aria-disabled]):last-of-type[data-focus]"
      )
    )
    |> assert_missing(
      Query.css(
        "#dropdown-with-disabled [role=menuitem]:not([aria-disabled]):first-of-type[data-focus]"
      )
    )
    |> assert_missing(
      Query.css("#dropdown-with-disabled [role=menuitem][aria-disabled=true][data-focus]")
    )
  end

  feature "mouse hover does not focus disabled items", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-with-disabled", "#dropdown-with-disabled")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Initially no item should be active
    |> assert_has(Query.css("#dropdown-with-disabled [role=menuitem][data-focus]", count: 0))
    # Hovering over disabled item should not activate it
    |> execute_script(
      "document.querySelector('#dropdown-with-disabled [role=menuitem][aria-disabled=true]').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_missing(
      Query.css("#dropdown-with-disabled [role=menuitem][aria-disabled=true][data-focus]")
    )
    |> assert_has(Query.css("#dropdown-with-disabled [role=menuitem][data-focus]", count: 0))
  end

  feature "clicking disabled items does not close menu", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-with-disabled", "#dropdown-with-disabled")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> click(@disabled_item)
    |> assert_has(@dropdown_menu |> Query.visible(true))
  end

  feature "aria-activedescendant management with disabled items", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-with-disabled", "#dropdown-with-disabled")
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Initially no aria-activedescendant
    |> assert_has(Query.css("#dropdown-with-disabled [role=menu]:not([aria-activedescendant])"))
    # After keyboard navigation to enabled item, aria-activedescendant should be set
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css(
        "#dropdown-with-disabled [role=menu][aria-activedescendant='dropdown-with-disabled-item-0']"
      )
    )
    # Navigate to next enabled item (skipping disabled), aria-activedescendant should update
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css(
        "#dropdown-with-disabled [role=menu][aria-activedescendant='dropdown-with-disabled-item-2']"
      )
    )
  end
end
