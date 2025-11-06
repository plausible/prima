defmodule DemoWeb.ModalTitleTest do
  use Prima.WallabyCase, async: true
  import Phoenix.LiveViewTest

  @modal_container Query.css("#demo-modal")
  @modal_title Query.css("#demo-modal [data-prima-ref=modal-title]")

  feature "modal title renders as h3 by default", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-modal", "#demo-modal")
    |> click(Query.css("#simple-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_title)
    |> assert_has(Query.css("#demo-modal h3[data-prima-ref=modal-title]"))
    |> assert_has(Query.css("#demo-modal h3[data-prima-ref=modal-title]", text: "Good news"))
  end

  feature "modal title can render as custom HTML tag", %{session: session} do
    session
    |> visit("/fixtures/modal-title-custom-tag")
    |> visit_fixture("/fixtures/modal-title-custom-tag", "#demo-modal")
    |> click(Query.css("#custom-tag-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_title)
    |> assert_has(Query.css("#demo-modal h1[data-prima-ref=modal-title]"))
    |> assert_has(
      Query.css("#demo-modal h1[data-prima-ref=modal-title]", text: "Custom Tag Title")
    )
  end

  feature "modal title can render as function component", %{session: session} do
    session
    |> visit("/fixtures/modal-title-function")
    |> visit_fixture("/fixtures/modal-title-function", "#demo-modal")
    |> click(Query.css("#function-modal button"))
    |> assert_has(@modal_container |> Query.visible(true))
    |> assert_has(@modal_title)
    |> assert_has(Query.css("#demo-modal span[data-prima-ref=modal-title].custom-title"))
    |> assert_has(
      Query.css("#demo-modal span[data-prima-ref=modal-title]", text: "Function Component Title")
    )
  end

  test "modal title raises error for invalid 'as' attribute" do
    import Prima.Modal

    assert_raise RuntimeError,
                 "Cannot render component `as` 123. Expected a function or string",
                 fn ->
                   render_component(&modal_title/1, %{as: 123}, %{})
                 end

    assert_raise RuntimeError,
                 "Cannot render component `as` []. Expected a function or string",
                 fn ->
                   render_component(&modal_title/1, %{as: []}, %{})
                 end

    assert_raise RuntimeError,
                 "Cannot render component `as` %{}. Expected a function or string",
                 fn ->
                   render_component(&modal_title/1, %{as: %{}}, %{})
                 end
  end
end
