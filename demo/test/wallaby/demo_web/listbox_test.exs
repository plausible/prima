defmodule DemoWeb.ListboxTest do
  use Prima.WallabyCase, async: true

  @button Query.css("#listbox [aria-haspopup=listbox]")
  @listbox Query.css("#listbox [role=listbox]")
  @options Query.css("#listbox [role=option]")
  @listbox_value Query.css("#listbox [data-prima-ref='value']")

  feature "default trigger has type='button' and aria-haspopup='listbox'", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> assert_has(Query.css("#listbox button[aria-haspopup=listbox][type=button]"))
  end

  feature "shows and hides the listbox when the trigger is clicked", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> assert_has(@listbox |> Query.visible(false))
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    |> assert_has(@options |> Query.count(4))
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(false))
  end

  feature "closes when clicking outside", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    |> click(Query.css("#outside-area"))
    |> assert_has(@listbox |> Query.visible(false))
  end

  feature "reflects the initial value on mount without opening the listbox", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> assert_has(@listbox_value |> Query.text("Banana"))
    |> assert_has(
      Query.css("#listbox-option-banana[aria-selected=true][data-selected]")
      |> Query.visible(false)
    )
    |> assert_missing(Query.css("#listbox-option-apple[aria-selected=true]"))
  end

  feature "selecting an option updates the hidden input, ARIA state, and displayed value instantly",
          %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> click(Query.css("#listbox-option-cherry"))
    |> assert_has(@listbox |> Query.visible(false))
    |> assert_has(@listbox_value |> Query.text("Cherry"))
    |> assert_has(
      Query.css("#listbox-option-cherry[aria-selected=true][data-selected]")
      |> Query.visible(false)
    )
    |> assert_missing(Query.css("#listbox-option-banana[aria-selected=true]"))
    |> then(fn session ->
      value =
        session
        |> find(
          Query.css("#listbox input[type=hidden][name=fruit_choice]")
          |> Query.visible(false)
        )
        |> Element.value()

      assert value == "cherry", "Expected hidden input value to be 'cherry' but got '#{value}'"

      session
    end)
  end

  feature "keeps the trailing icon after a selection updates the displayed value", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> click(Query.css("#listbox-option-apple"))
    |> assert_has(@listbox_value |> Query.text("Apple"))
    |> assert_has(Query.css("#listbox-trigger-icon"))
  end

  feature "disabled options cannot be selected", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> click(Query.css("#listbox-option-durian"))
    |> assert_has(@listbox |> Query.visible(true))
    |> assert_has(@listbox_value |> Query.text("Banana"))
  end

  feature "keyboard navigation skips disabled options and wraps around", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> send_keys([:down_arrow])
    |> assert_has(Query.css("#listbox-option-apple[data-focus]"))
    # Up from the first enabled option wraps to the last *enabled* option (cherry, skipping durian)
    |> send_keys([:up_arrow])
    |> assert_has(Query.css("#listbox-option-cherry[data-focus]"))
    |> assert_missing(Query.css("#listbox-option-durian[data-focus]"))
  end

  feature "aria-activedescendant is managed on the trigger button, not the listbox", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> assert_has(Query.css("#listbox [aria-haspopup=listbox]:not([aria-activedescendant])"))
    |> send_keys([:down_arrow])
    |> assert_has(
      Query.css("#listbox [aria-haspopup=listbox][aria-activedescendant='listbox-option-apple']")
    )
    |> assert_has(Query.css("#listbox [role=listbox]:not([aria-activedescendant])"))
    |> send_keys([:escape])
    |> assert_has(Query.css("#listbox [aria-haspopup=listbox]:not([aria-activedescendant])"))
  end

  feature "Opening and closing listbox with keyboard (Enter, Space, Esc)", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    # Escape closes the listbox, but keeps focus on the
    # trigger button, letting Enter/Space open it again.
    |> send_keys([:escape])
    |> assert_has(@listbox |> Query.visible(false))
    |> send_keys([" "])
    |> assert_has(@listbox |> Query.visible(true))
    |> assert_has(Query.css("#listbox-option-banana[data-focus]"))
    |> send_keys([:escape])
    |> assert_has(@listbox |> Query.visible(false))
    |> send_keys([:enter])
    |> assert_has(@listbox |> Query.visible(true))
    |> assert_has(Query.css("#listbox-option-banana[data-focus]"))
  end

  feature "aria-controls/aria-labelledby relationships are set from the given IDs", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> assert_has(
      Query.css("#listbox-trigger[aria-haspopup=listbox][aria-controls='listbox-options']")
    )
    |> assert_has(
      Query.css("#listbox-options[role=listbox][aria-labelledby='listbox-trigger']")
      |> Query.visible(false)
    )
  end

  feature "remains functional after LiveView reconnection", %{session: session} do
    session
    |> visit_fixture("/fixtures/listbox", "#listbox")
    |> execute_script("window.liveSocket.disconnect()")
    |> execute_script("window.liveSocket.connect()")
    # Wait for reconnection by checking for the data attribute that gets set
    |> assert_has(Query.css(".phx-connected[data-phx-main]"))
    |> assert_has(@listbox_value |> Query.text("Banana"))
    |> click(@button)
    |> assert_has(@listbox |> Query.visible(true))
    |> click(Query.css("#listbox-option-apple"))
    |> assert_has(@listbox_value |> Query.text("Apple"))
  end
end
