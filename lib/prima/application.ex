defmodule Prima.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PrimaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Prima.PubSub},
      # Start the Endpoint (http/https)
      PrimaWeb.Endpoint
      # Start a worker by calling: Prima.Worker.start_link(arg)
      # {Prima.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prima.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrimaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
