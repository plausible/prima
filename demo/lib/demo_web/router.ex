defmodule DemoWeb.Router do
  @moduledoc false
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", DemoWeb do
    pipe_through :browser

    live "/", DemoLive, :introduction
    live "/dropdown", DemoLive, :dropdown
    live "/modal", DemoLive, :modal
    live "/modal/history", DemoLive, :modal_history
    live "/combobox", DemoLive, :combobox

    if Mix.env() in [:dev, :test] do
      live "/fixtures/dropdown", FixturesLive, :dropdown
      live "/fixtures/dropdown-with-disabled", FixturesLive, :dropdown_with_disabled
      live "/fixtures/simple-modal", FixturesLive, :simple_modal
      live "/fixtures/async-modal", FixturesLive, :async_modal
      live "/fixtures/modal-title-custom-tag", FixturesLive, :modal_title_custom_tag
      live "/fixtures/modal-title-function", FixturesLive, :modal_title_function
      live "/fixtures/modal-focus-autofocus", FixturesLive, :modal_focus_autofocus
      live "/fixtures/simple-combobox", FixturesLive, :simple_combobox
      live "/fixtures/async-combobox", FixturesLive, :async_combobox
      live "/fixtures/creatable-combobox", FixturesLive, :creatable_combobox
      live "/fixtures/flexible-markup-combobox", FixturesLive, :flexible_markup_combobox
      live "/fixtures/multi-select-combobox", FixturesLive, :multi_select_combobox
      live "/fixtures/combobox-form-tab", FixturesLive, :combobox_form_tab
      live "/fixtures/overflow-combobox", FixturesLive, :overflow_combobox
      live "/fixtures/display-value-combobox", FixturesLive, :display_value_combobox
      live "/fixtures/combobox-change", FixturesLive, :combobox_change
      live "/fixtures/async-combobox-form-change", FixturesLive, :async_combobox_form_change
    end
  end
end
