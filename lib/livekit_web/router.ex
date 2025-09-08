defmodule LivekitWeb.Router do
  @moduledoc false
  use LivekitWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LivekitWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LivekitWeb do
    pipe_through :browser

    live "/demo", DemoLive, :introduction
    live "/demo/dropdown", DemoLive, :dropdown
    live "/demo/modal", DemoLive, :modal
    live "/demo/modal/history", DemoLive, :modal_history
    live "/demo/combobox", DemoLive, :combobox

    if Mix.env() in [:dev, :test] do
      live "/fixtures/dropdown", FixturesLive, :dropdown
      live "/fixtures/simple-modal", FixturesLive, :simple_modal
      live "/fixtures/async-modal", FixturesLive, :async_modal
    end

    get "/", PageController, :home
  end
end
