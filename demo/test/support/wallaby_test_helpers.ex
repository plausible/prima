defmodule Prima.WallabyTestHelpers do
  @moduledoc "Test helpers for headless browser tests"
  import Wallaby.Browser
  import ExUnit.Assertions, only: [assert: 1]
  alias Wallaby.Query

  @doc """
  A better alternative to refute_has. The built-in refute_has will wait up to 3 seconds for the element to appear before giving up. This slows down the tests a lot.
  Assert_missing will return immediately if the element is indeed missing from DOM.
  """
  def assert_missing(session, query) do
    assert_has(session, query |> Query.count(0))
  end

  def visit_fixture(session, pathname, selector) do
    session
    |> visit(pathname)
    |> wait_for_hook_ready(selector)
  end

  def assert_combobox_selection(session, selector, name, label, value) do
    execute_script(
      session,
      """
      const root = document.querySelector(#{Jason.encode!(selector)});
      return {
        search: root.querySelector('[data-prima-ref=search_input]').value,
        submit: new FormData(root.closest('form')).get(#{Jason.encode!(name)})
      };
      """,
      fn result -> assert result == %{"search" => label, "submit" => value} end
    )
  end

  defp wait_for_hook_ready(session, selector) do
    session
    |> assert_has(Query.css("#{selector}[data-prima-ready='true']", visible: :any))
  end
end
