defmodule LiveKitWeb.AsyncModalTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @modal_panel Query.css("#demo-form-modal [livekit-ref=modal-panel]")
  @modal_overlay Query.css("#demo-form-modal [livekit-ref=modal-overlay]")
  @modal_container Query.css("#demo-form-modal")
  @modal_loader Query.css("#demo-form-modal [livekit-ref=modal-loader]")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit("/fixtures/async-modal")
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # In async mode, panel is not mounted in the DOM until the modal is opened
    |> refute_has(@modal_panel)
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
    # TODO
    assert true
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
    |> refute_has(@modal_panel)
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
    |> refute_has(@modal_panel)
  end

  feature "race condition - when old modal is closed and new one opened quickly, only new one is shown",
          %{session: session} do
    session =
      session
      |> visit("/demo/modal")
      |> click(Query.css("#open-form-modal-button"))
      |> assert_has(@modal_panel |> Query.visible(true))
      |> execute_script("document.querySelector('#demo-form-modal h2').innerHTML = 'Dirty Modal'")
      |> execute_script("window.liveSocket.enableLatencySim(1000)")
      |> send_keys([:escape])
      # Wait for modal to close before reopening - with latency sim, this takes longer
      |> assert_has(@modal_container |> Query.visible(false))
      |> refute_has(@modal_panel)
      |> click(Query.css("#open-form-modal-button"))
      # Wait for the loader to appear first (immediate)
      |> assert_has(@modal_loader |> Query.visible(true))
      # Give time for async modal to load (1000ms) + latency sim (1000ms)
      |> execute_script("return new Promise(resolve => setTimeout(resolve, 2100))")
      # Wait for panel to appear (delayed due to async loading + latency sim)
      |> assert_has(@modal_panel |> Query.visible(true))
      # Verify the fresh content eventually appears (critical part of race condition test)
      |> assert_text(Query.css("#demo-form-modal h2"), "Data loaded successfully")
      |> execute_script("window.liveSocket.disableLatencySim()")
  end
end
