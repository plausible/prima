defmodule DemoWeb.MultipleModalsPushEventTest do
  use Prima.WallabyCase, async: true

  @modal_one_panel Query.css("#modal-one [data-prima-ref=modal-panel]")
  @modal_one_overlay Query.css("#modal-one [data-prima-ref=modal-overlay]")
  @modal_one_container Query.css("#modal-one")

  @modal_two_panel Query.css("#modal-two [data-prima-ref=modal-panel]")
  @modal_two_overlay Query.css("#modal-two [data-prima-ref=modal-overlay]")
  @modal_two_container Query.css("#modal-two")

  feature "opens specific modal when ID is provided in payload", %{session: session} do
    session
    |> visit_fixture("/fixtures/multiple-modals-push-event", "#modal-one")
    # Both modals initially hidden
    |> assert_has(@modal_one_container |> Query.visible(false))
    |> assert_has(@modal_two_container |> Query.visible(false))
    # Open modal one via push_event with specific ID
    |> click(Query.button("Open Modal One via Backend"))
    # Only modal one should open
    |> assert_has(@modal_one_container |> Query.visible(true))
    |> assert_has(@modal_one_overlay |> Query.visible(true))
    |> assert_has(@modal_one_panel |> Query.visible(true))
    # Modal two should remain closed
    |> assert_has(@modal_two_container |> Query.visible(false))
  end

  feature "closes specific modal when ID is provided in payload", %{session: session} do
    session
    |> visit_fixture("/fixtures/multiple-modals-push-event", "#modal-one")
    # Open modal one
    |> click(Query.button("Open Modal One via Backend"))
    |> assert_has(@modal_one_container |> Query.visible(true))
    |> assert_has(@modal_one_panel |> Query.visible(true))
    # Close modal one via push_event with specific ID
    |> click(Query.css("#backend-close-modal-one"))
    # Modal one should close
    |> assert_has(@modal_one_container |> Query.visible(false))
    |> assert_has(@modal_one_overlay |> Query.visible(false))
    |> assert_has(@modal_one_panel |> Query.visible(false))
    # Open modal two and close it via push_event
    |> click(Query.button("Open Modal Two via Backend"))
    |> assert_has(@modal_two_container |> Query.visible(true))
    |> assert_has(@modal_two_panel |> Query.visible(true))
    |> click(Query.css("#backend-close-modal-two"))
    # Modal two should close
    |> assert_has(@modal_two_container |> Query.visible(false))
    |> assert_has(@modal_two_overlay |> Query.visible(false))
    |> assert_has(@modal_two_panel |> Query.visible(false))
  end

  feature "can target different modals independently", %{session: session} do
    session
    |> visit_fixture("/fixtures/multiple-modals-push-event", "#modal-one")
    # Open modal two
    |> click(Query.button("Open Modal Two via Backend"))
    |> assert_has(@modal_two_container |> Query.visible(true))
    |> assert_has(@modal_one_container |> Query.visible(false))
    # Close modal two and open modal one
    |> click(Query.css("#backend-close-modal-two"))
    |> assert_has(@modal_two_container |> Query.visible(false))
    |> click(Query.button("Open Modal One via Backend"))
    |> assert_has(@modal_one_container |> Query.visible(true))
    |> assert_has(@modal_two_container |> Query.visible(false))
  end
end
