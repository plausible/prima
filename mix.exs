defmodule Prima.MixProject do
  use Mix.Project
  @source_url "https://github.com/plausible/prima"

  def project do
    [
      name: "Prima",
      description: "Unstyled, accessible components for LiveView applications",
      app: :prima,
      version: "0.2.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, ">= 1.7.0"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_view, "~> 1.1"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild library"],
      "docs.serve": ["docs", "cmd open doc/index.html"],

      # Demo application convenience aliases
      "phx.server": ["cmd cd demo && mix phx.server"],
      test: ["cmd cd demo && mix test"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv mix.exs README.md LICENSE package.json)
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
