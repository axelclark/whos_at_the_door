defmodule WhosAtTheDoor.MixProject do
  use Mix.Project

  def project do
    [
      app: :whos_at_the_door,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WhosAtTheDoor.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grovepi, github: "adkron/grovepi", branch: "master"}
    ]
  end
end
