defmodule LiveKitWeb.AsyncModalTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  def assert_missing(session, query) do
    assert_has(session, query |> Query.count(0))
  end

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

  feature "race condition - when old modal is closed and new one opened quickly, only new one is shown",
          %{session: session} do
    session =
      session
      |> visit("/fixtures/async-modal")
      |> click(Query.css("#open-form-modal-button"))
      |> assert_has(@modal_panel |> Query.visible(true))
      |> execute_script("document.querySelector('#demo-form-modal h2').innerHTML = 'Dirty Modal'")
      |> send_keys([:escape])
      |> assert_has(@modal_container |> Query.visible(false))
      |> assert_missing(@modal_panel)
      |> click(Query.css("#open-form-modal-button"))
      |> assert_has(@modal_loader |> Query.visible(true))
      |> assert_has(@modal_panel |> Query.visible(true))
      # Verify the fresh content eventually appears
      |> assert_text(Query.css("#demo-form-modal h2"), "Data loaded successfully")
      |> execute_script("window.liveSocket.disableLatencySim()")
  end
end
