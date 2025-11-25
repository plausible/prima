defmodule DemoWeb.ModalPushEventTest do
  use Prima.WallabyCase, async: true

  @frontend_modal_panel Query.css("#frontend-modal [data-prima-ref=modal-panel]")
  @frontend_modal_overlay Query.css("#frontend-modal [data-prima-ref=modal-overlay]")
  @frontend_modal_container Query.css("#frontend-modal")

  @modal_one_panel Query.css("#modal-one [data-prima-ref=modal-panel]")
  @modal_one_overlay Query.css("#modal-one [data-prima-ref=modal-overlay]")
  @modal_one_container Query.css("#modal-one")

  @modal_two_panel Query.css("#modal-two [data-prima-ref=modal-panel]")
  @modal_two_overlay Query.css("#modal-two [data-prima-ref=modal-overlay]")
  @modal_two_container Query.css("#modal-two")

  feature "closes frontend modal when backend sends push_event", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-push-event", "#frontend-modal")
    |> assert_has(@frontend_modal_container |> Query.visible(false))
    |> click(Query.button("Open Frontend Modal"))
    |> assert_has(@frontend_modal_container |> Query.visible(true))
    |> assert_has(@frontend_modal_overlay |> Query.visible(true))
    |> assert_has(@frontend_modal_panel |> Query.visible(true))
    |> assert_has(Query.css("#backend-close-button") |> Query.visible(true))
    |> click(Query.css("#backend-close-button"))
    |> assert_has(@frontend_modal_container |> Query.visible(false))
    |> assert_has(@frontend_modal_overlay |> Query.visible(false))
    |> assert_has(@frontend_modal_panel |> Query.visible(false))
  end

  feature "opens frontend modal when backend sends push_event", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-push-event", "#frontend-modal")
    |> assert_has(@frontend_modal_container |> Query.visible(false))
    |> assert_has(@frontend_modal_overlay |> Query.visible(false))
    |> assert_has(@frontend_modal_panel |> Query.visible(false))
    |> click(Query.css("#backend-open-button"))
    |> assert_has(@frontend_modal_container |> Query.visible(true))
    |> assert_has(@frontend_modal_overlay |> Query.visible(true))
    |> assert_has(@frontend_modal_panel |> Query.visible(true))
  end

  feature "opens specific modal when ID is provided in payload", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-push-event", "#modal-one")
    |> assert_has(@modal_one_container |> Query.visible(false))
    |> assert_has(@modal_two_container |> Query.visible(false))
    |> click(Query.button("Open Modal One via Backend"))
    |> assert_has(@modal_one_container |> Query.visible(true))
    |> assert_has(@modal_one_overlay |> Query.visible(true))
    |> assert_has(@modal_one_panel |> Query.visible(true))
    |> assert_has(@modal_two_container |> Query.visible(false))
  end

  feature "closes specific modal when ID is provided in payload", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-push-event", "#modal-one")
    |> click(Query.button("Open Modal One via Backend"))
    |> assert_has(@modal_one_container |> Query.visible(true))
    |> assert_has(@modal_one_panel |> Query.visible(true))
    |> click(Query.css("#backend-close-modal-one"))
    |> assert_has(@modal_one_container |> Query.visible(false))
    |> assert_has(@modal_one_overlay |> Query.visible(false))
    |> assert_has(@modal_one_panel |> Query.visible(false))
    |> click(Query.button("Open Modal Two via Backend"))
    |> assert_has(@modal_two_container |> Query.visible(true))
    |> assert_has(@modal_two_panel |> Query.visible(true))
    |> click(Query.css("#backend-close-modal-two"))
    |> assert_has(@modal_two_container |> Query.visible(false))
    |> assert_has(@modal_two_overlay |> Query.visible(false))
    |> assert_has(@modal_two_panel |> Query.visible(false))
  end

  feature "can target different modals independently", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-push-event", "#modal-one")
    |> click(Query.button("Open Modal Two via Backend"))
    |> assert_has(@modal_two_container |> Query.visible(true))
    |> assert_has(@modal_one_container |> Query.visible(false))
    |> click(Query.css("#backend-close-modal-two"))
    |> assert_has(@modal_two_container |> Query.visible(false))
    |> click(Query.button("Open Modal One via Backend"))
    |> assert_has(@modal_one_container |> Query.visible(true))
    |> assert_has(@modal_two_container |> Query.visible(false))
  end
end
