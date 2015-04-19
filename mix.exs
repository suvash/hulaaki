defmodule Hulaaki.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :hulaaki,
     version: @version,
     name: "Hulaaki",
     elixir: "~> 1.0",
     source_url: "https://github.com/suvash/hulaaki",
     homepage_url: "https://github.com/suvash/hulaaki",
     deps: deps,
     docs: &docs/0,

     description: description,
     package: package,

     test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:inch_ex, "~> 0.2.4", only: :docs},
     {:earmark, "~> 0.1", only: [:dev, :docs]},
     {:ex_doc, "~> 0.7", only: [:dev, :docs]},
     {:dialyze, "~> 0.1.3", only: :test},
     {:excoveralls, "~> 0.3", only: [:dev, :test]}]
  end

  defp description do
    """
    An MQTT 3.1.1 client library written in Elixir.
    """
  end

  defp package do
    [contributors: ["Suvash Thapaliya"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/suvash/hulaaki"}]
  end

  defp docs do
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
    [readme: "README.md", main: "README",
     source_ref: ref, source_url: "https://github.com/suvash/hulaaki"]
  end
end
