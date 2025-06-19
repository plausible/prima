defmodule LiveKitWeb.AsyncModalTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @modal_panel Query.css("#demo-form-modal [livekit-ref=modal-panel]")
  @modal_overlay Query.css("#demo-form-modal [livekit-ref=modal-overlay]")
  @modal_container Query.css("#async-form-modal #demo-form-modal")
  @modal_loader Query.css("#demo-form-modal [livekit-ref=modal-loader]")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit("/demo/modal")
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
     # In async mode, panel is not mounted in the DOM until the modal is opened
    |> refute_has(@modal_panel)
    |> click(Query.css("#async-form-modal button"))
    # Loader is shown while panel is loading
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
    |> visit("/demo/modal")
    |> click(Query.css("#async-form-modal button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # Panel is removed from the DOM when the modal is closed
    |> refute_has(@modal_panel)
  end

  feature "modal can be closed from the backend (e.g. when form is submitted)", %{session: session} do
    session
    |> visit("/demo/modal")
    |> click(Query.css("#async-form-modal button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> click(Query.button("Save"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    # Panel is removed from the DOM when the modal is closed
    |> refute_has(@modal_panel)
  end

  feature "race condition - when old modal is closed and new one opened quickly, only new one is shown", %{session: session} do
    session
    |> visit("/demo/modal")
    |> click(Query.css("#async-form-modal #open-form-modal-button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> execute_script("document.querySelector('form h2').innerHTML = 'Dirty Modal'")
    |> execute_script("window.liveSocket.enableLatencySim(1000)")
    |> send_keys([:escape])
    |> click(Query.css("#async-form-modal #open-form-modal-button"))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> assert_text(Query.css("form h2"), "New item form")
    |> execute_script("window.liveSocket.disableLatencySim()")
  end
end
