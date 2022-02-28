defmodule Bennu.MixProject do
  use Mix.Project
  
  @version (case File.read("VERSION") do
    {:ok, version} -> String.trim(version)
    {:error, _} -> "0.0.0-development"
  end)

  def project do
    [
      app: :bennu,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: package(version),
      # dialyxir
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore",
        plt_add_apps: [
          :mix,
          :ex_unit
        ]
      ],
      # docs
      name: "Bennu",
      source_url: "https://github.com/coingaming/bennu",
      homepage_url: "https://github.com/coingaming/bennu/tree/v#{@version}",
      docs: [
        source_ref: "v#{@version}"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      organization: "coingaming",
      licenses: ["UNLICENSED"],
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "VERSION"],
      links: %{
        "GitHub" => "https://github.com/coingaming/bennu/tree/v#{@version}"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_enum, "~> 0.4", organization: "coingaming"},
      {:typable, "~> 0.3"},
      {:defnamed, "~> 0.1.3"},
      {:meme, "~> 0.2", organization: "coingaming"},

      # dev tools
      {:excoveralls, "~> 0.11", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:benchwarmer, "~> 0.0.2", only: [:dev, :test], runtime: false},
      {:benchfella, "~> 0.3.0", only: :bench, runtime: false}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      setup: ["./setup"],
      docs: ["docs", "cmd mkdir -p doc/priv/img/", "cmd cp -R priv/img/ doc/priv/img/", "docs"]
    ]
  end
end
