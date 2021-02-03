defmodule Bennu.MixProject do
  use Mix.Project

  def project do
    [
      app: :bennu,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      # dialyxir
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore",
        plt_add_apps: [
          :mix,
          :ex_unit
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.5.7"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.14.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.4"},
      {:ecto_sql, "~> 3.2"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.2"},
      {:gen_enum, "~> 0.4", organization: "coingaming"},
      {:typable, "~> 0.3"},
      {:defnamed, "~> 0.1.3"},
      {:selectable, github: "coingaming/selectable"},
      {:readable, "~> 0.1.0"},
      {:meme, "~> 0.2", organization: "coingaming"},
      {:earmark, "~> 1.3.5"},
      {:phoenix_slime, "~> 0.13.1"},
      # dev tools
      {:excoveralls, "~> 0.11", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:benchwarmer, "~> 0.0.2", only: [:dev, :test], runtime: false},
      {:benchfella, "~> 0.3.0", only: :bench, runtime: false}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      docs: ["docs", "cmd mkdir -p doc/priv/img/", "cmd cp -R priv/img/ doc/priv/img/", "docs"]
    ]
  end
end
