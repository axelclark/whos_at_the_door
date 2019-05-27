# Who's At The Door
A nerves project using an ultrasonic ranger to detect visitors or intruders

This project reads an ultrasonic ranger sensor and updates a RGB LCD
display to greet a visitor with the total number of visitors.  Press
the button to arm the alarm. When an intruder arrives, the LED turns on,
the RGB LCD display turns red, and the buzzer buzzes.  Press the button
again to reset the system.

On the GrovePi+ or GrovePi Zero, connect the following devices:
  * Button: Port A0
  * Buzzer: Port A1
  * LED: Port A2
  * Ultrasonic Ranger: Port D3
  * RGB LCD display:  IC2-1 port

This project was created as a Nerves app. To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with `export MIX_TARGET=my_target`, Example: `export MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`
