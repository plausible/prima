defmodule Prima.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:prima, :start_demo_app, false) do
        [
          PrimaWeb.Telemetry,
          {Phoenix.PubSub, name: Prima.PubSub},
          PrimaWeb.Endpoint
        ]
      else
        # When used as a library, don't start demo application components
        []
      end

    opts = [strategy: :one_for_one, name: Prima.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PrimaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
