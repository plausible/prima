defmodule DemoWeb.FrontendModalPushEventTest do
  use Prima.WallabyCase, async: true

  @modal_panel Query.css("#frontend-modal [data-prima-ref=modal-panel]")
  @modal_overlay Query.css("#frontend-modal [data-prima-ref=modal-overlay]")
  @modal_container Query.css("#frontend-modal")

  feature "closes frontend modal when backend sends push_event", %{session: session} do
    session
    |> visit_fixture("/fixtures/frontend-modal-push-event", "#frontend-modal")
    # Verify modal is initially hidden
    |> assert_has(@modal_container |> Query.visible(false))
    # Open the modal
    |> click(Query.button("Open Frontend Modal"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    # Verify the backend button exists and is visible
    |> assert_has(Query.css("#backend-close-button") |> Query.visible(true))
    # Click the backend button that triggers push_event to close the modal
    # This button is INSIDE the modal panel, so it won't trigger click-away
    |> click(Query.css("#backend-close-button"))
    # The modal should close via push_event - this will FAIL if the hook
    # doesn't have handleEvent to receive the "close-modal" event
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end
end
