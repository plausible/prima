defmodule PrimaWeb.Router do
  @moduledoc false
  use PrimaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PrimaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PrimaWeb do
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
      live "/fixtures/simple-combobox", FixturesLive, :simple_combobox
      live "/fixtures/async-combobox", FixturesLive, :async_combobox
      live "/fixtures/creatable-combobox", FixturesLive, :creatable_combobox
      live "/fixtures/flexible-markup-combobox", FixturesLive, :flexible_markup_combobox
      live "/fixtures/multi-select-combobox", FixturesLive, :multi_select_combobox
    end
  end
end
