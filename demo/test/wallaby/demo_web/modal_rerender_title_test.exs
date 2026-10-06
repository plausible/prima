defmodule DemoWeb.ModalRerenderTitleTest do
  use Prima.WallabyCase, async: true

  @modal_panel Query.css("#demo-modal [data-prima-ref=modal-panel]")
  @modal_container Query.css("#demo-modal")
  @open_button Query.css("#modal-rerender button", text: "Open Modal")
  @update_button Query.css("#update-title")
  @update_button_inside Query.css("#update-title-inside")

  feature "removing an open modal restores focus and body scrolling", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-rerender-title", "#demo-modal")
    |> click(@open_button)
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> click(Query.css("#remove-modal"))
    |> assert_missing(Query.css("#demo-modal", visible: :any))
    |> assert_has(Query.css("#modal-rerender button:focus", text: "Open Modal"))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
  end

  feature "dismissed initially shown modal stays closed through rerender and reconnect", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/modal-rerender-title?show=true", "#demo-modal")
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> click(@update_button)
    |> assert_has(Query.css("#update-title[data-title='Updated Title']"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> execute_script("window.liveSocket.disconnect()")
    |> execute_script("window.liveSocket.connect()")
    |> assert_has(Query.css(".phx-connected[data-phx-main]"))
    |> assert_has(@modal_container |> Query.visible(false))
    |> click(@open_button)
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> send_keys([:escape])
    |> assert_has(Query.css("#modal-rerender button:focus", text: "Open Modal"))
  end

  feature "initially shown modal preserves focus and scroll restoration across a rerender", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/modal-rerender-title?show=true", "#demo-modal")
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> click(@update_button_inside)
    |> assert_has(Query.css("#demo-modal-title", text: "Updated Title"))
    |> assert_has(Query.css("#update-title-inside:focus"))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> execute_script("return document.body.style.overflow", fn overflow ->
      assert overflow == ""
    end)
  end

  feature "title rerenders preserve accessibility and open/close behavior", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-rerender-title", "#demo-modal")
    |> click(@open_button)
    |> assert_has(Query.css("#demo-modal[aria-labelledby='demo-modal-title']"))
    |> assert_has(Query.css("#demo-modal-title", text: "Good news"))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> click(@update_button)
    |> assert_has(Query.css("#update-title[data-title='Updated Title']"))
    |> click(@open_button)
    |> assert_has(@modal_panel |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal[aria-labelledby='demo-modal-title']"))
    |> assert_has(Query.css("#demo-modal-title", text: "Updated Title"))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
  end

  feature "modal remains open when re-rendered while open", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-rerender-title", "#demo-modal")
    |> click(@open_button)
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal-title", text: "Good news"))
    |> click(@update_button_inside)
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_panel |> Query.visible(true))
    |> assert_has(Query.css("#demo-modal-title", text: "Updated Title"))
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
  end
end
