defmodule Demo.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      releases: [
        demo: [
          applications: [
            demo: :permanent,
            prima: :permanent
          ]
        ]
      ]
    ]
  end

  def application do
    [
      mod: {Demo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Library dependency from parent directory (repository root)
      {:prima, path: ".."},

      # Phoenix framework
      {:phoenix, ">= 1.7.0"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},

      # Assets
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.4.0", runtime: Mix.env() == :dev},

      # Server
      {:plug_cowboy, "~> 2.5"},

      # Telemetry
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},

      # Testing
      {:wallaby, "~> 0.30", runtime: false, only: :test},
      {:lazy_html, ">= 0.0.0", only: :test},

      # Dev tools
      {:tidewave, "~> 0.5", only: [:dev]},
      {:autumn, "~> 0.5", only: [:dev]},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "cmd --cd assets npm install"
      ],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      test: ["assets.build", "test"]
    ]
  end
end
