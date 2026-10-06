defmodule DemoWeb.ModalFocusTest do
  use Prima.WallabyCase, async: true

  @modal_container Query.css("#demo-modal")
  @autofocus_modal_container Query.css("#autofocus-modal")

  feature "default focus is restored across repeated opens and closes", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> execute_script("""
    document.querySelector('#demo-modal').dispatchEvent(new Event('prima:modal:open'))
    """)
    |> send_keys([:escape])
    |> assert_has(@modal_container |> Query.visible(false))
    |> assert_has(Query.css("#simple-modal button:focus"))
    |> click(Query.css("#simple-modal button"))
    |> assert_has(Query.css("#demo-modal [testing-ref=close-button]:focus"))
    |> send_keys([:escape])
    |> assert_has(Query.css("#simple-modal button:focus"))
  end

  feature "backend open and close restore focus to the trigger", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-push-event", "#frontend-modal")
    |> click(Query.button("Open Modal One via Backend"))
    |> assert_has(Query.css("#modal-one [testing-ref=modal-one-close]:focus"))
    |> click(Query.css("#backend-close-modal-one"))
    |> assert_has(Query.css("#modal-one", visible: false))
    |> assert_has(Query.css("#modal-push-event button:focus", text: "Open Modal One via Backend"))
  end

  feature "autofocus is applied on open and restored to the trigger on close", %{session: session} do
    session
    |> visit_fixture("/fixtures/modal-focus-autofocus", "#autofocus-modal")
    |> click(Query.css("#modal-focus-autofocus button"))
    |> assert_has(Query.css("#autofocus-modal [testing-ref=autofocus-input]:focus"))
    |> send_keys([:escape])
    |> assert_has(@autofocus_modal_container |> Query.visible(false))
    |> assert_has(Query.css("#modal-focus-autofocus button:focus"))
  end
end
