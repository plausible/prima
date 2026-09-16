defmodule DemoWeb.ListboxTransitionTest do
  use Prima.WallabyCase, async: true

  @button Query.css("#listbox-transition [aria-haspopup=listbox]")
  @listbox Query.css("#listbox-transition [role=listbox]")

  describe "with an enter transition configured" do
    feature "stays open after the same click that opened it", %{session: session} do
      session
      |> visit_fixture("/fixtures/listbox-with-transition", "#listbox-transition")
      |> assert_has(@listbox |> Query.visible(false))
      |> click(@button)
      |> assert_has(@listbox |> Query.visible(true))
      |> assert_has(Query.css("#listbox-transition [role=option]") |> Query.count(3))
    end

    feature "still closes on a genuine outside click", %{session: session} do
      session
      |> visit_fixture("/fixtures/listbox-with-transition", "#listbox-transition")
      |> click(@button)
      |> assert_has(@listbox |> Query.visible(true))
      |> click(Query.css("#outside-area"))
      |> assert_has(@listbox |> Query.visible(false))
    end

    feature "still closes after selection an option", %{session: session} do
      session
      |> visit_fixture("/fixtures/listbox-with-transition", "#listbox-transition")
      |> click(@button)
      |> assert_has(@listbox |> Query.visible(true))
      |> click(Query.css("#listbox-transition-option-cherry"))
      |> assert_has(@listbox |> Query.visible(false))
      |> assert_has(
        Query.css("#listbox-transition-trigger [data-prima-ref='value']", text: "Cherry")
      )
    end
  end
end
