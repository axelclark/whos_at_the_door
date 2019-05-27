defmodule WhosAtTheDoor do
  @moduledoc false
  use GenServer
  require Logger

  defstruct [
    :button_pin,
    :buzzer_pin,
    :led_pin,
    :ultrasonic_pin,
    greeting: false,
    visits: 0,
    armed?: false
  ]

  alias GrovePi.{Button, Buzzer, Digital, RGBLCD, Ultrasonic}

  @five_seconds 5000
  @one_second 1000

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  ## Callbacks

  @impl true
  def init(opts) do
    button_pin = opts[:button_pin]
    buzzer_pin = opts[:buzzer_pin]
    led_pin = opts[:led_pin]
    ultrasonic_pin = opts[:ultrasonic_pin]

    state = %__MODULE__{
      button_pin: button_pin,
      buzzer_pin: buzzer_pin,
      led_pin: led_pin,
      ultrasonic_pin: ultrasonic_pin
    }

    {:ok, state, {:continue, :start_and_subscribe}}
  end

  @impl true
  def handle_continue(:start_and_subscribe, state) do
    Ultrasonic.subscribe(state.ultrasonic_pin, :changed)
    Button.subscribe(state.button_pin, :pressed)
    Digital.set_pin_mode(state.led_pin, :output)
    led_off(state)
    RGBLCD.initialize()
    display_waiting_message(state)
    {:noreply, state}
  end

  @impl true
  def handle_info({_pin, :changed, %{value: value}}, state) do
    state =
      if in_range?(value) do
        state
        |> maybe_greet_visitor()
        |> maybe_sound_alarm()
      else
        state
      end

    log_distance(value)
    {:noreply, state}
  end

  @impl true
  def handle_info({_pin, :pressed, _value}, state) do
    armed? = !state.armed?
    Logger.info("Pressed. armed?: #{armed?}")

    case armed? do
      true ->
        display_armed_message()

      false ->
        display_waiting_message(state)
    end

    {:noreply, %{state | armed?: armed?}}
  end

  @impl true
  def handle_info(:reset_greeting, state) do
    display_waiting_message(state)
    {:noreply, %{state | greeting: false}}
  end

  @impl true
  def handle_info(_message, state) do
    {:noreply, state}
  end

  ## Helpers

  defp display_armed_message() do
    RGBLCD.set_text("Armed...")
  end

  defp display_hello_message(state) do
    RGBLCD.set_text("Hello! You are")
    RGBLCD.set_cursor(1, 0)
    RGBLCD.write_text("visitor #" <> Integer.to_string(state.visits))
    state
  end

  defp display_intruder_message(state) do
    led_on(state)
    RGBLCD.set_rgb(255, 0, 0)
    RGBLCD.set_text("Intruder alert!")
  end

  defp display_waiting_message(state) do
    led_off(state)
    RGBLCD.set_color_white()
    RGBLCD.set_text("Waiting for a")
    RGBLCD.set_cursor(1, 0)
    RGBLCD.write_text("visitor!")
  end

  defp in_range?(value) when value < 100, do: true
  defp in_range?(_value), do: false

  defp led_off(state) do
    GrovePi.Digital.write(state.led_pin, 0)
  end

  defp led_on(state) do
    GrovePi.Digital.write(state.led_pin, 1)
  end

  defp log_distance(value) do
    value
    |> ultrasonic_distance()
    |> Logger.info()
  end

  defp maybe_greet_visitor(%{greeting: false, armed?: false} = state) do
    schedule_greeting_reset()
    Logger.info("Greet visitor")

    state
    |> update_greeting_and_visits()
    |> display_hello_message()
  end

  defp maybe_greet_visitor(state), do: state

  defp maybe_sound_alarm(%{armed?: true} = state) do
    Logger.info("Sound alarm!!")
    display_intruder_message(state)
    Buzzer.buzz(state.buzzer_pin, @one_second)
    state
  end

  defp maybe_sound_alarm(state), do: state

  defp schedule_greeting_reset() do
    Process.send_after(self(), :reset_greeting, @five_seconds)
  end

  defp ultrasonic_distance(value) when is_integer(value) do
    Integer.to_string(value) <> " cm away"
  end

  defp update_greeting_and_visits(state) do
    state
    |> Map.replace!(:greeting, true)
    |> Map.replace!(:visits, state.visits + 1)
  end
end
