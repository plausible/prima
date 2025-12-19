defmodule DemoWeb.DropdownCustomIdsTest do
  use Prima.WallabyCase, async: true

  feature "honors user-provided ID on dropdown_trigger", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-custom-ids", "#dropdown-custom-ids")
    |> assert_has(Query.css("#my-custom-trigger[aria-haspopup=menu]"))
    |> assert_has(Query.css("#my-custom-trigger[aria-controls='my-custom-menu']"))
  end

  feature "honors user-provided ID on dropdown_menu", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-custom-ids", "#dropdown-custom-ids")
    |> assert_has(Query.css("#my-custom-menu[role=menu]") |> Query.visible(false))
    |> assert_has(
      Query.css("#my-custom-menu[aria-labelledby='my-custom-trigger']")
      |> Query.visible(false)
    )
  end

  feature "honors user-provided IDs on dropdown_item elements", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-custom-ids", "#dropdown-custom-ids")
    |> click(Query.css("#my-custom-trigger"))
    |> assert_has(Query.css("#my-item-1[role=menuitem]"))
    |> assert_has(Query.css("#my-item-2[role=menuitem]"))
  end

  feature "uses custom IDs in aria-activedescendant", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-custom-ids", "#dropdown-custom-ids")
    |> click(Query.css("#my-custom-trigger"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#my-custom-menu[aria-activedescendant='my-item-1']"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#my-custom-menu[aria-activedescendant='my-item-2']"))
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#my-custom-menu[aria-activedescendant='dropdown-custom-ids-item-2']")
    )
  end

  feature "maintains ARIA relationships with custom IDs after LiveView reconnection", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-custom-ids", "#dropdown-custom-ids")
    |> execute_script("window.liveSocket.disconnect()")
    |> execute_script("window.liveSocket.connect()")
    |> assert_has(Query.css(".phx-connected[data-phx-main]"))
    |> assert_has(Query.css("#my-custom-trigger[aria-controls='my-custom-menu']"))
    |> assert_has(
      Query.css("#my-custom-menu[aria-labelledby='my-custom-trigger']")
      |> Query.visible(false)
    )
    |> click(Query.css("#my-custom-trigger"))
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#my-custom-menu[aria-activedescendant='my-item-1']"))
  end
end
