defmodule LiveKitWeb.ModalTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @modal_panel Query.css("#simple-modal [livekit-ref=modal-panel]")
  @modal_overlay Query.css("#simple-modal [livekit-ref=modal-overlay]")

  feature "shows modal when button is clicked", %{session: session} do
    session
    |> visit("/demo")
    # |> refute_has(Query.css("#simple-modal #demo-modal", visible: true))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
    |> click(Query.css("#simple-modal button"))
    # |> assert_has(Query.css("#simple-modal #demo-modal", visible: true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
  end

  feature "closes modal when user clicks close button", %{session: session} do
    session
    |> visit("/demo")
    |> click(Query.css("#simple-modal button"))
    # |> assert_has(Query.css("#simple-modal #demo-modal", visible: true))
    |> assert_has(@modal_overlay |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> click(Query.css("#simple-modal [testing-ref=close-button]"))
    |> wait_for(Query.css("#simple-modal [livekit-ref=modal-panel]", visible: false))
    |> assert_has(@modal_overlay |> Query.visible(false))
    |> assert_has(@modal_panel |> Query.visible(false))
  end

  def wait_for(session, query) do
    retry(fn -> execute_query(session, query) end)
    session
  end
end
