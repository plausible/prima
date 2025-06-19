defmodule LiveKitWeb.SimpleModalTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @modal_panel Query.css("#simple-modal [livekit-ref=modal-panel]")
  @modal_overlay Query.css("#simple-modal [livekit-ref=modal-overlay]")
  @modal_container Query.css("#simple-modal #demo-modal")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit("/demo/modal")
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
    |> visit("/demo/modal")
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
    |> visit("/demo/modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end
end
