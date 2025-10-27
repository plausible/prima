defmodule PrimaWeb.ComboboxAriaTest do
  use Prima.WallabyCase, async: true

  @combobox_input Query.css("#demo-combobox input[role=combobox]")
  @options_container Query.css("#demo-combobox [data-prima-ref=options]")

  feature "combobox input has role=combobox attribute", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(@combobox_input)
  end

  feature "aria-expanded toggles between true and false based on dropdown state", %{
    session: session
  } do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    # Initially closed - aria-expanded should be false
    |> assert_has(Query.css("#demo-combobox input[aria-expanded=false]"))
    |> assert_has(@options_container |> Query.visible(false))
    # Open options - aria-expanded should be true
    |> click(@combobox_input)
    |> assert_has(@options_container |> Query.visible(true))
    |> assert_has(Query.css("#demo-combobox input[aria-expanded=true]"))
    # Close by clicking outside - aria-expanded should be false again
    |> click(Query.css("body"))
    |> assert_has(@options_container |> Query.visible(false))
    |> assert_has(Query.css("#demo-combobox input[aria-expanded=false]"))
  end

  feature "aria-controls references the options container ID", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(
      Query.css("#demo-combobox input[role=combobox][aria-controls='demo-combobox-options']")
    )
  end

  feature "options container has role=listbox attribute", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(Query.css("#demo-combobox-options[role=listbox]") |> Query.visible(false))
  end

  feature "aria-activedescendant tracks the focused option", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    # Initially no aria-activedescendant when closed
    |> assert_missing(Query.css("#demo-combobox input[aria-activedescendant]"))
    # Open options
    |> click(@combobox_input)
    |> assert_has(@options_container |> Query.visible(true))
    # First option should be focused, input should have aria-activedescendant pointing to it
    |> execute_script(
      "const input = document.querySelector('#demo-combobox input[role=combobox]'); const firstOption = document.querySelector('#demo-combobox [role=option][data-focus=true]'); return {inputAria: input.getAttribute('aria-activedescendant'), optionId: firstOption ? firstOption.id : null}",
      fn result ->
        assert result["optionId"] != nil, "Expected first option to have an ID"

        assert result["inputAria"] == result["optionId"],
               "Expected aria-activedescendant to match focused option ID"
      end
    )
    # Navigate down to second option
    |> send_keys([:down_arrow])
    |> execute_script(
      "const input = document.querySelector('#demo-combobox input[role=combobox]'); const focusedOption = document.querySelector('#demo-combobox [role=option][data-focus=true]'); return {inputAria: input.getAttribute('aria-activedescendant'), optionId: focusedOption ? focusedOption.id : null}",
      fn result ->
        assert result["optionId"] != nil, "Expected second option to have an ID"

        assert result["inputAria"] == result["optionId"],
               "Expected aria-activedescendant to match focused option ID after navigation"
      end
    )
  end

  feature "combobox input has aria-autocomplete=list attribute", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(Query.css("#demo-combobox input[role=combobox][aria-autocomplete=list]"))
  end

  feature "combobox input has aria-haspopup=listbox attribute", %{session: session} do
    session
    |> visit_fixture("/fixtures/simple-combobox", "#demo-combobox")
    |> assert_has(Query.css("#demo-combobox input[role=combobox][aria-haspopup=listbox]"))
  end
end
