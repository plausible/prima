defmodule PrimaWeb.ComboboxTabNavigationTest do
  use Prima.WallabyCase, async: true

  @combobox_input Query.css("#demo-combobox input[data-prima-ref=search_input]")
  @next_input Query.css("#next-input")
  @options_container Query.css("#demo-combobox [data-prima-ref=options]")

  feature "tab key moves focus to next input when options are closed", %{session: session} do
    session
    |> visit_fixture("/fixtures/combobox-form-tab", "#demo-combobox")
    |> assert_has(@combobox_input)
    |> assert_has(@next_input)
    # Click on the combobox input to focus it (but options should be closed)
    |> execute_script(
      "document.querySelector('#demo-combobox input[data-prima-ref=search_input]').focus()"
    )
    # Verify options are closed
    |> assert_has(@options_container |> Query.visible(false))
    # Press Tab - should move focus to next input
    |> send_keys([:tab])
    # Verify focus moved to next input (browser default behavior)
    |> execute_script(
      "return document.activeElement.id",
      fn active_id ->
        assert active_id == "next-input",
               "Expected focus to move to next-input, but active element is '#{active_id}'"
      end
    )
    # Options should still be closed
    |> assert_has(@options_container |> Query.visible(false))
  end
end
