# Who's At The Door
A nerves project using an ultrasonic ranger to detect visitors

This project reads an ultrasonic ranger sensor and updates a
RGB LCD display to greet a visitor with the total number of visitors.

On the GrovePi+ or GrovePi Zero, connect a Ultrasonic Ranger to port 3 and a RGB LCD display
to the IC2-1 port.

This project was created as a Nerves app. To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with `export MIX_TARGET=my_target`, Example: `export MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`
