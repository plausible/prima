defmodule DemoWeb.ModalRerenderTitleTest do
  use Prima.WallabyCase, async: true

  @modal_panel Query.css("#demo-modal [data-prima-ref=modal-panel]")
  @modal_container Query.css("#demo-modal")
  @open_button Query.css("#modal-rerender button", text: "Open Modal")
  @update_button Query.css("#update-title")
  @update_button_inside Query.css("#update-title-inside")

  feature "modal remains functional after title is re-rendered", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-rerender-title", "#demo-modal")
    # Open modal
    |> click(@open_button)
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    # Close modal
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    # Trigger LiveView update that re-renders the title
    |> click(@update_button)
    # Open modal again - tests that DOM listeners are still intact
    |> click(@open_button)
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    # Verify the title was updated
    |> assert_has(Query.css("#demo-modal [data-prima-ref=modal-title]", text: "Updated Title"))
    # Close with escape to verify keyboard listener works
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
  end

  feature "ARIA attributes are correctly set after title is re-rendered", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-rerender-title", "#demo-modal")
    # Open modal and verify initial ARIA relationships
    |> click(@open_button)
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal[aria-labelledby='demo-modal-title']"))
    |> assert_has(Query.css("#demo-modal-title", text: "Good news"))
    # Close modal
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    # Trigger LiveView update that re-renders the title
    |> click(@update_button)
    # Open modal again
    |> click(@open_button)
    |> assert_has(@modal_container |> Query.visible(true))
    # Verify ARIA relationships are still correct after re-render
    |> assert_has(Query.css("#demo-modal[aria-labelledby='demo-modal-title']"))
    |> assert_has(Query.css("#demo-modal-title", text: "Updated Title"))
  end

  feature "modal remains open when re-rendered while open", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-rerender-title", "#demo-modal")
    # Open modal
    |> click(@open_button)
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal-title", text: "Good news"))
    # Trigger LiveView update while modal is open (using button inside modal)
    |> click(@update_button_inside)
    # Modal should remain open and show updated content
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal-title", text: "Updated Title"))
    # Modal should still be functional - close with escape
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
  end
end
