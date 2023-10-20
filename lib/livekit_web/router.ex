defmodule LivekitWeb.Router do
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

    live "/demo", DemoLive

    get "/", PageController, :home
  end
end
