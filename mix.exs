defmodule Prima.MixProject do
  use Mix.Project
  @source_url "https://github.com/plausible/prima"

  def project do
    [
      name: "Prima",
      description: "Unstyled, accessible components for LiveView applications",
      app: :prima,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      docs: docs(),
      compilers: [:phoenix_live_view] ++ Mix.compilers()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Prima.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:lazy_html, ">= 0.0.0", only: :test},
      {:phoenix, "~> 1.7.18"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:plug_cowboy, "~> 2.5"},
      {:autumn, "~> 0.5"},
      {:wallaby, "~> 0.30", runtime: false, only: :test},
      {:tidewave, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default", "esbuild library"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "docs.serve": ["docs", "cmd open doc/index.html"],
      test: [
        "esbuild default",
        "test"
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      exclude_patterns: [
        "lib/prima_web.ex",
        "lib/prima_web",
        "priv/static",
        "priv/code_examples"
      ],
      files: ~w(lib priv mix.exs README.md LICENSE .formatter.exs),
      extra_files: ~w(assets/js/prima.js)
    ]
  end

  defp docs do
    [
      main: "Prima",
      source_url: @source_url,
      homepage_url: @source_url,
      extras: ["README.md"],
      groups_for_modules: [
        Components: [
          Prima.Modal,
          Prima.Dropdown,
          Prima.Combobox
        ]
      ],
      groups_for_extras: [
        Guides: ["README.md"]
      ]
    ]
  end
end
