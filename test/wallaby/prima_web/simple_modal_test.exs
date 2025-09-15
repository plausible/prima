defmodule PrimaWeb.SimpleModalTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @modal_panel Query.css("#simple-modal [prima-ref=modal-panel]")
  @modal_overlay Query.css("#simple-modal [prima-ref=modal-overlay]")
  @modal_container Query.css("#simple-modal #demo-modal")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
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
    |> visit("/fixtures/simple-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> click(Query.css("#simple-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end

  feature "closes modal when user hits escape key", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
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
    |> visit("/fixtures/simple-modal")
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == "hidden"
    end)
    |> click(Query.css("#simple-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
  end

  feature "modal has proper ARIA attributes", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
    # Modal should have role="dialog" and aria-modal="true" even when hidden
    |> assert_has(Query.css("#simple-modal #demo-modal[role=dialog][aria-modal=true]") |> Query.visible(false))
  end

  feature "auto-generates ARIA label relationships", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # Modal should have auto-generated aria-labelledby pointing to modal title
    |> assert_has(Query.css("#simple-modal #demo-modal[aria-labelledby='demo-modal-title']"))
    # The title element should exist with matching ID
    |> assert_has(Query.css("#simple-modal #demo-modal-title"))
  end

  feature "focus management when modal opens and closes", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
    # Focus the trigger button first
    |> execute_script("document.querySelector('#simple-modal button').focus()")
    |> assert_has(Query.css("#simple-modal button:focus"))
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # Focus should move into the modal (to the first focusable element - close button)
    |> assert_has(Query.css("#simple-modal [testing-ref=close-button]:focus"))
    # Close with escape key
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    # Focus should return to the trigger button
    |> assert_has(Query.css("#simple-modal button:focus"))
  end

  feature "manages aria-hidden state for background content", %{session: session} do
    session
    |> visit("/fixtures/simple-modal")
    # Initially modal should be hidden
    |> assert_has(Query.css("#simple-modal #demo-modal[aria-hidden=true]") |> Query.visible(false))
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # When modal is open, it should not have aria-hidden
    |> assert_has(Query.css("#simple-modal #demo-modal:not([aria-hidden])"))
    # Close modal
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    # Modal should have aria-hidden=true again when closed
    |> assert_has(Query.css("#simple-modal #demo-modal[aria-hidden=true]") |> Query.visible(false))
  end
end
