defmodule PrimaWeb.SimpleModalTest do
  use Prima.WallabyCase, async: true

  @modal_panel Query.css("#demo-modal [data-prima-ref=modal-panel]")
  @modal_overlay Query.css("#demo-modal [data-prima-ref=modal-overlay]")
  @modal_container Query.css("#demo-modal")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
  end

  feature "closes modal when user clicks close button", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> click(Query.css("#demo-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end

  feature "closes modal when user hits escape key", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end

  feature "prevents body scroll when modal is open", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == "hidden"
    end)
    |> click(Query.css("#demo-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
  end

  feature "modal has proper ARIA attributes", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
    # Modal should have role="dialog" and aria-modal="true" even when hidden
    |> assert_has(
      Query.css("#demo-modal[role=dialog][aria-modal=true]")
      |> Query.visible(false)
    )
  end

  feature "auto-generates ARIA label relationships", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # Modal should have auto-generated aria-labelledby pointing to modal title
    |> assert_has(Query.css("#demo-modal[aria-labelledby='demo-modal-title']"))
    # The title element should exist with matching ID
    |> assert_has(Query.css("#demo-modal-title"))
  end

  feature "manages aria-hidden state for background content", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    # Initially modal should be hidden
    |> assert_has(
      Query.css("#demo-modal[aria-hidden=true]")
      |> Query.visible(false)
    )
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # When modal is open, it should not have aria-hidden
    |> assert_has(Query.css("#demo-modal:not([aria-hidden])"))
    # Close modal
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    # Modal should have aria-hidden=true again when closed
    |> assert_has(
      Query.css("#demo-modal[aria-hidden=true]")
      |> Query.visible(false)
    )
  end

  feature "modal remains functional after LiveView reconnection", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    # Test multiple reconnections to see if event listeners accumulate
    |> execute_script("window.liveSocket.disconnect()")
    |> execute_script("window.liveSocket.connect()")
    |> assert_has(Query.css(".phx-connected[data-phx-main]"))
    # Test basic open/close functionality
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # Focus should move to the first focusable element (close button)
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> click(Query.css("#demo-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
  end
end
