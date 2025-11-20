defmodule DemoWeb.DropdownRerenderTriggerTest do
  use Prima.WallabyCase, async: true

  @dropdown_button Query.css("#dropdown [aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown [role=menu]")
  @update_button Query.css("#update-trigger")

  feature "dropdown remains functional after trigger is re-rendered", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-rerender-trigger", "#dropdown")
    # Verify initial state
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Open dropdown
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Close dropdown
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Trigger LiveView update that re-renders the trigger button
    |> click(@update_button)
    # Wait for the trigger to update
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu]", text: "Updated Trigger"))
    # Try to open dropdown again - this tests that DOM listeners are still intact
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
  end

  feature "dropdown keyboard navigation works after trigger is re-rendered", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-rerender-trigger", "#dropdown")
    # Open and close dropdown
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
    # Trigger LiveView update
    |> click(@update_button)
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu]", text: "Updated Trigger"))
    # Open dropdown and verify keyboard navigation works
    |> click(@dropdown_button)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown [role=menuitem]:first-child[data-focus]"))
    |> send_keys([:escape])
    |> assert_has(@dropdown_menu |> Query.visible(false))
  end

  feature "ARIA attributes are correctly set after trigger is re-rendered", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-rerender-trigger", "#dropdown")
    # Verify initial ARIA relationships
    |> assert_has(
      Query.css(
        "#dropdown [aria-haspopup=menu][id='dropdown-trigger'][aria-controls='dropdown-menu']"
      )
    )
    |> assert_has(
      Query.css("#dropdown [role=menu][id='dropdown-menu'][aria-labelledby='dropdown-trigger']")
      |> Query.visible(false)
    )
    # Trigger LiveView update that re-renders the trigger button
    |> click(@update_button)
    |> assert_has(Query.css("#dropdown [aria-haspopup=menu]", text: "Updated Trigger"))
    # Verify ARIA relationships are still correct after re-render
    |> assert_has(
      Query.css(
        "#dropdown [aria-haspopup=menu][id='dropdown-trigger'][aria-controls='dropdown-menu']"
      )
    )
    |> assert_has(
      Query.css("#dropdown [role=menu][id='dropdown-menu'][aria-labelledby='dropdown-trigger']")
      |> Query.visible(false)
    )
  end
end
