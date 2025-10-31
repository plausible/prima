defmodule Prima.WallabyTestHelpers do
  @moduledoc "Test helpers for headless browser tests"
  import Wallaby.Browser
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

  defp wait_for_hook_ready(session, selector) do
    session
    |> assert_has(Query.css("#{selector}[data-prima-ready='true']", visible: :any))
  end
end
