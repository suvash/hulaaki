defmodule Hulaaki.Mixfile do
  use Mix.Project

  def project do
    [app: :hulaaki,
     version: "0.0.1",
     name: "Hulaaki",
     elixir: "~> 1.0",
     source_url: "https://github.com/suvash/hulaaki",
     homepage_url: "https://github.com/suvash/hulaaki",
     deps: deps,
     test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:inch_ex, "~> 0.2.4", only: :docs},
     {:earmark, "~> 0.1", only: [:dev, :docs]},
     {:ex_doc, "~> 0.7", only: [:dev, :docs]},
     {:dialyze, "~> 0.1.3", only: :test},
     {:excoveralls, "~> 0.3", only: [:dev, :test]}]
  end
end
