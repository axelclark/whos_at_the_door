defmodule WhosAtTheDoor.Application do
  @moduledoc false

  @button_pin 14
  @buzzer_pin 15
  @led_pin 16
  @ultrasonic_pin 3

  @one_second 1_00

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    pins = [
      button_pin: @button_pin,
      buzzer_pin: @buzzer_pin,
      led_pin: @led_pin,
      ultrasonic_pin: @ultrasonic_pin
    ]

    children = [
      worker(GrovePi.Ultrasonic, [@ultrasonic_pin, [poll_interval: @one_second]]),
      {GrovePi.Button, @button_pin},
      {GrovePi.Buzzer, @buzzer_pin},
      {WhosAtTheDoor, pins}
    ]

    opts = [strategy: :one_for_one, name: WhosAtTheDoor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
