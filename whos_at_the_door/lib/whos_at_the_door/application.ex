defmodule WhosAtTheDoor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  # Use port 3 for the ultrasonic
  @ultrasonic_pin 3
  # poll every 1 second
  @ultrasonic_poll_interval 1_00

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: WhosAtTheDoor.Worker.start_link(arg)
      worker(GrovePi.Ultrasonic, [@ultrasonic_pin, [poll_interval: @ultrasonic_poll_interval]]),
      {WhosAtTheDoor, @ultrasonic_pin}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WhosAtTheDoor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
