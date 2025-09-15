defmodule PrimaWeb.ModalDemoPageTest do
  use PrimaWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "modal demo page" do
    test "loads without errors and shows basic page content", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demo/modal")

      assert html =~ "Modal"
      assert html =~ "fully-managed dialog component"
      assert html =~ "Quick Start"
      assert html =~ "Advanced Usage"
    end

    test "renders minimal modal code example", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demo/modal")

      assert html =~ "Prima.Modal.open"
      assert html =~ "Open Modal"
      assert html =~ "Hello Modal"
    end

    test "renders form modal events code example", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demo/modal")

      assert html =~ "handle_event"
      assert html =~ "open-form-modal"
      assert html =~ "close-form-modal"
    end

    test "renders form modal template code example", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demo/modal")

      assert html =~ "modal_panel"
    end

    test "renders history routes code example", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demo/modal")

      assert html =~ "live_action"
      assert html =~ "show_history_modal"
      assert html =~ "handle_params"
    end

    test "applies syntax highlighting to code examples", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/demo/modal")

      assert html =~ "athl"
      assert html =~ "prima-code-block"
    end
  end
end
