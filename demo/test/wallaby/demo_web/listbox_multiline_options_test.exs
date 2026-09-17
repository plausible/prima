defmodule DemoWeb.ListboxMultilineOptionsTest do
  use Prima.WallabyCase, async: true

  @listbox_button Query.css("#listbox-multiline [aria-haspopup=listbox]")
  @listbox Query.css("#listbox-multiline [role=listbox]")

  feature "mouse hover tracks the cursor when options have multiple child elements", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox-multiline-options", "#listbox-multiline")
    |> click(@listbox_button)
    |> assert_has(@listbox |> Query.visible(true))
    # Hovering over a child element inside the apple option (not the option
    # itself) should still focus it.
    |> execute_script(
      "document.querySelector('#listbox-multiline-option-apple div:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#listbox-multiline-option-apple[data-focus]"))
    # Hovering over a child element inside the cherry option should move
    # focus there and clear it from the apple option.
    |> execute_script(
      "document.querySelector('#listbox-multiline-option-cherry div:last-child').dispatchEvent(new MouseEvent('mouseover', {bubbles: true}))"
    )
    |> assert_has(Query.css("#listbox-multiline-option-cherry[data-focus]"))
    |> assert_missing(Query.css("#listbox-multiline-option-apple[data-focus]"))
  end

  feature "clicking a child element inside an option selects it, closes the listbox, and refocuses the trigger",
          %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox-multiline-options", "#listbox-multiline")
    |> click(@listbox_button)
    |> assert_has(@listbox |> Query.visible(true))
    # Click lands on the child div, not the [role=option] element itself.
    |> click(Query.css("#listbox-multiline-option-cherry div:last-child"))
    |> assert_has(@listbox |> Query.visible(false))
    |> assert_has(Query.css("#listbox-multiline-trigger:focus"))
    |> assert_has(
      Query.css("#listbox-multiline-option-cherry[aria-selected=true]")
      |> Query.visible(false)
    )
  end
end
