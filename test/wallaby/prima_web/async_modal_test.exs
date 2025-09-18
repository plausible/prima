defmodule PrimaWeb.AsyncModalTest do
  use Prima.WallabyCase, async: true

  @modal_panel Query.css("#demo-form-modal [prima-ref=modal-panel]")
  @modal_overlay Query.css("#demo-form-modal [prima-ref=modal-overlay]")
  @modal_container Query.css("#demo-form-modal")
  @modal_loader Query.css("#demo-form-modal [prima-ref=modal-loader]")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit("/fixtures/async-modal")
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # In async mode, panel is not mounted in the DOM until the modal is opened
    |> assert_missing(@modal_panel)
    |> click(Query.css("#open-form-modal-button"))
    # Loader is shown while panel is loading (check early since it might hide quickly)
    |> assert_has(@modal_loader |> Query.visible(true))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    # Loader is hidden once panel has mounted
    |> assert_has(@modal_loader |> Query.visible(false))
  end

  feature "closes modal when user clicks close button", %{session: session} do
    session
    |> visit("/fixtures/async-modal")
    |> click(Query.css("#open-form-modal-button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> click(Query.css("[testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # Panel is removed from the DOM when the modal is closed
    |> assert_missing(@modal_panel)
  end

  feature "closes modal when user hits escape key", %{session: session} do
    session
    |> visit("/fixtures/async-modal")
    |> click(Query.css("#open-form-modal-button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # Panel is removed from the DOM when the modal is closed
    |> assert_missing(@modal_panel)
  end

  feature "modal can be closed from the backend (e.g. when form is submitted)", %{
    session: session
  } do
    session
    |> visit("/fixtures/async-modal")
    |> click(Query.css("#open-form-modal-button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> click(Query.button("Save"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # Panel is removed from the DOM when the modal is closed
    |> assert_missing(@modal_panel)
  end

  feature "async modal has proper ARIA attributes and relationships", %{session: session} do
    session
    |> visit("/fixtures/async-modal")
    # Modal should have proper ARIA attributes even when hidden
    |> assert_has(
      Query.css("#demo-form-modal[role=dialog][aria-modal=true][aria-hidden=true]")
      |> Query.visible(false)
    )
    |> click(Query.css("#open-form-modal-button"))
    |> assert_has(@modal_overlay |> Query.visible(true))
    # Wait for async content to load
    |> assert_has(@modal_panel |> Query.visible(true))
    # Modal should have aria-labelledby pointing to auto-generated title ID
    |> assert_has(Query.css("#demo-form-modal[aria-labelledby='demo-form-modal-title']"))
    # The title element should exist with matching ID
    |> assert_has(Query.css("#demo-form-modal-title"))
    # Modal should not have aria-hidden when open
    |> assert_has(Query.css("#demo-form-modal:not([aria-hidden])"))
  end

  feature "race condition - when old modal is closed and new one opened quickly, only new one is shown",
          %{session: session} do
    session
    |> visit("/fixtures/async-modal")
    |> click(Query.css("#open-form-modal-button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> execute_script(
      "document.querySelector('#demo-form-modal [prima-ref=\"modal-title\"]').innerHTML = 'Dirty Modal'"
    )
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_missing(@modal_panel)
    |> click(Query.css("#open-form-modal-button"))
    |> assert_has(@modal_loader |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    # Verify the fresh content eventually appears
    |> assert_text(
      Query.css("#demo-form-modal [prima-ref=\"modal-title\"]"),
      "Data loaded successfully"
    )
    |> execute_script("window.liveSocket.disableLatencySim()")
  end
end
