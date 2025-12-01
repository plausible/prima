defmodule DemoWeb.DropdownCustomComponentsTest do
  use Prima.WallabyCase, async: true

  @dropdown_container Query.css("#dropdown-custom")
  @dropdown_trigger Query.css("#dropdown-custom button[aria-haspopup=menu]")
  @dropdown_menu Query.css("#dropdown-custom [role=menu]")

  feature "dropdown_trigger as custom component receives accessibility attributes", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-custom-components", "#dropdown-custom")
    |> assert_has(@dropdown_container)
    |> assert_has(@dropdown_trigger)
    |> assert_has(Query.css("#dropdown-custom button[aria-haspopup='menu']"))
    |> assert_has(Query.css("#dropdown-custom button[aria-expanded='false']"))
    |> assert_has(Query.css("#dropdown-custom button[data-custom-attr='test-value']"))
  end

  feature "dropdown_item as custom component receives accessibility attributes", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-custom-components", "#dropdown-custom")
    |> click(@dropdown_trigger)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown-custom a[role=menuitem]") |> Query.count(2))
    |> assert_has(Query.css("#dropdown-custom a[role=menuitem][tabindex='-1']") |> Query.count(2))
    |> assert_has(Query.css("#dropdown-custom a[role=menuitem]:nth-child(2)", text: "Link Item"))
    |> assert_has(
      Query.css("#dropdown-custom a[role=menuitem][data-phx-link='redirect']", text: "Link Item")
    )
  end

  feature "dropdown_item disabled attribute is passed through to custom component", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/dropdown-custom-components", "#dropdown-custom")
    |> click(@dropdown_trigger)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    |> assert_has(Query.css("#dropdown-custom a[role=menuitem][aria-disabled='true']"))
    |> assert_has(
      Query.css("#dropdown-custom a[role=menuitem][aria-disabled='true'][data-disabled='true']")
    )
    |> assert_has(
      Query.css("#dropdown-custom [role=menuitem]:nth-child(3)", text: "Disabled Link")
    )
  end

  feature "keyboard navigation works with custom component items", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-custom-components", "#dropdown-custom")
    |> click(@dropdown_trigger)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Navigate down to first item (regular div)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-custom [role=menuitem]:nth-child(1)[data-focus]"))
    # Navigate down to second item (link)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#dropdown-custom a[role=menuitem]:nth-child(2)[data-focus]"))
    |> assert_missing(Query.css("#dropdown-custom [role=menuitem]:nth-child(1)[data-focus]"))
  end

  feature "pressing Enter on a focused link item navigates to the link", %{session: session} do
    session
    |> visit_fixture("/fixtures/dropdown-custom-components", "#dropdown-custom")
    |> click(@dropdown_trigger)
    |> assert_has(@dropdown_menu |> Query.visible(true))
    # Navigate down to the link item (which links to "/")
    |> send_keys([:down_arrow])
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#dropdown-custom a[role=menuitem]:nth-child(2)[data-focus]", text: "Link Item")
    )
    # Press Enter to follow the link
    |> send_keys([:enter])
    # Should navigate away from the fixture page - the dropdown should no longer exist
    |> assert_missing(@dropdown_container)
  end
end
