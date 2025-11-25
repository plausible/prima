defmodule DemoWeb.ModalWithoutPortalTest do
  use Prima.WallabyCase, async: true

  @modal_panel Query.css("#no-portal-modal [data-prima-ref=modal-panel]")
  @modal_overlay Query.css("#no-portal-modal [data-prima-ref=modal-overlay]")
  @modal_container Query.css("#no-portal-modal")

  feature "modal without portal shows when button is clicked", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
  end

  feature "modal without portal closes when user clicks close button", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> click(Query.css("#no-portal-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end

  feature "modal without portal closes on escape key", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end

  feature "modal without portal prevents body scroll", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == "hidden"
    end)
    |> click(Query.css("#no-portal-modal [testing-ref=close-button]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
  end

  feature "modal without portal has proper ARIA attributes", %{session: session} do
    session
    |> visit("/fixtures/modal-without-portal")
    |> assert_has(
      Query.css("#no-portal-modal[role=dialog][aria-modal=true]")
      |> Query.visible(false)
    )
  end

  feature "modal without portal manages aria-hidden state", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> assert_has(
      Query.css("#no-portal-modal[aria-hidden=true]")
      |> Query.visible(false)
    )
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(Query.css("#no-portal-modal:not([aria-hidden])"))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(
      Query.css("#no-portal-modal[aria-hidden=true]")
      |> Query.visible(false)
    )
  end

  feature "modal without portal auto-generates ARIA label relationships", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(Query.css("#no-portal-modal[aria-labelledby='no-portal-modal-title']"))
    |> assert_has(Query.css("#no-portal-modal-title"))
  end

  feature "modal without portal manages focus correctly", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-without-portal", "#no-portal-modal")
    |> click(Query.css("#modal-without-portal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(Query.css("#no-portal-modal [testing-ref=close-button]:focus"))
  end
end
