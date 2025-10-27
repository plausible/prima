defmodule PrimaWeb.ModalFocusTest do
  use Prima.WallabyCase, async: true

  @modal_container Query.css("#focus-default-modal")
  @autofocus_modal_container Query.css("#autofocus-modal")

  feature "focuses first focusable element when no autofocus element present", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-focus-default", "#focus-default-modal")
    |> click(Query.css("#modal-focus-default button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # The first focusable element (close button) should be focused
    |> assert_has(Query.css("#focus-default-modal [testing-ref=close-button]:focus"))
  end

  feature "focuses element with data-autofocus when present", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-focus-autofocus", "#autofocus-modal")
    |> click(Query.css("#modal-focus-autofocus button"))
    |> assert_has(@autofocus_modal_container |> Query.visible(true))
    # The input with data-autofocus should be focused
    |> assert_has(Query.css("#autofocus-modal [testing-ref=autofocus-input]:focus"))
  end

  feature "restores focus to trigger when modal closes with autofocus", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-focus-autofocus", "#autofocus-modal")
    # Focus the trigger button first
    |> execute_script("document.querySelector('#modal-focus-autofocus button').focus()")
    |> assert_has(Query.css("#modal-focus-autofocus button:focus"))
    |> click(Query.css("#modal-focus-autofocus button"))
    |> assert_has(@autofocus_modal_container |> Query.visible(true))
    # Close with escape key
    |> send_keys([:escape])
    |> assert_has(@autofocus_modal_container |> Query.visible(false))
    # Focus should return to the trigger button
    |> assert_has(Query.css("#modal-focus-autofocus button:focus"))
  end

  feature "restores focus to trigger when modal closes with default focus", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-focus-default", "#focus-default-modal")
    # Focus the trigger button first
    |> execute_script("document.querySelector('#modal-focus-default button').focus()")
    |> assert_has(Query.css("#modal-focus-default button:focus"))
    |> click(Query.css("#modal-focus-default button"))
    |> assert_has(@modal_container |> Query.visible(true))
    # Close with escape key
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    # Focus should return to the trigger button
    |> assert_has(Query.css("#modal-focus-default button:focus"))
  end
end
