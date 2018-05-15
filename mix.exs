defmodule Uelli.Mixfile do
  use Mix.Project

  def project do
    [
      app: :uelli,
      version: ("VERSION" |> File.read! |> String.trim),
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      # excoveralls
      test_coverage:      [tool: ExCoveralls],
      preferred_cli_env:  [
        "coveralls":            :test,
        "coveralls.travis":     :test,
        "coveralls.circle":     :test,
        "coveralls.semaphore":  :test,
        "coveralls.post":       :test,
        "coveralls.detail":     :test,
        "coveralls.html":       :test,
      ],
      # dialyxir
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore",
        plt_add_apps: [
          :mix
        ]
      ],
      # ex_doc
      name:         "Uelli",
      source_url:   "https://github.com/timCF/uelli",
      homepage_url: "https://github.com/timCF/uelli",
      docs:         [main: "readme", extras: ["README.md"]],
      # hex.pm stuff
      description:  "Elixir utilities and custom guards",
      package: [
        licenses: ["Apache 2.0"],
        files: ["lib", "priv", "mix.exs", "README*", "VERSION*"],
        maintainers: ["Ilja Tkachuk aka timCF"],
        links: %{
          "GitHub" => "https://github.com/timCF/uelli",
          "Author's home page" => "https://timcf.github.io/",
        }
      ],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {Uelli, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # development tools
      {:excoveralls, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5",    only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.18",     only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8",       only: [:dev, :test], runtime: false},
      {:boilex, "~> 0.2",      only: [:dev, :test], runtime: false},
    ]
  end
end
