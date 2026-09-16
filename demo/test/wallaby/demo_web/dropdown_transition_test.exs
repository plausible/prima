defmodule DemoWeb.DropdownTransitionTest do
  use Prima.WallabyCase, async: true

  @button Query.css("#dropdown-transition [aria-haspopup=menu]")
  @menu Query.css("#dropdown-transition [role=menu]")

  describe "with an enter transition configured" do
    feature "stays open after the same click that opened it", %{session: session} do
      session
      |> visit_fixture("/fixtures/dropdown-with-transition", "#dropdown-transition")
      |> assert_has(@menu |> Query.visible(false))
      |> click(@button)
      |> assert_has(@menu |> Query.visible(true))
      |> assert_has(Query.css("#dropdown-transition [role=menuitem]") |> Query.count(3))
    end

    feature "still closes on a genuine outside click", %{session: session} do
      session
      |> visit_fixture("/fixtures/dropdown-with-transition", "#dropdown-transition")
      |> click(@button)
      |> assert_has(@menu |> Query.visible(true))
      |> click(Query.css("#outside-area"))
      |> assert_has(@menu |> Query.visible(false))
    end

    feature "still closes after clicking a menu item", %{session: session} do
      session
      |> visit_fixture("/fixtures/dropdown-with-transition", "#dropdown-transition")
      |> click(@button)
      |> assert_has(@menu |> Query.visible(true))
      |> click(Query.css("#dropdown-transition-item-0"))
      |> assert_has(@menu |> Query.visible(false))
    end
  end
end
