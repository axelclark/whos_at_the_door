defmodule WhosAtTheDoor do
  @moduledoc false
  use GenServer
  require Logger

  defstruct ultrasonic: nil, greeting: false, visits: 0

  alias GrovePi.{RGBLCD, Ultrasonic}

  @five_seconds 5000

  ## Client API

  def start_link(pin) do
    GenServer.start_link(__MODULE__, pin)
  end

  ## Callbacks

  @impl true
  def init(ultrasonic_pin) do
    state = %__MODULE__{ultrasonic: ultrasonic_pin}
    {:ok, state, {:continue, :start_and_subscribe}}
  end

  @impl true
  def handle_continue(:start_and_subscribe, state) do
    Ultrasonic.subscribe(state.ultrasonic, :changed)
    RGBLCD.initialize()
    waiting_message()
    {:noreply, state}
  end

  @impl true
  def handle_info({_pin, :changed, %{value: value}}, %{greeting: false} = state)
      when value < 100 do
    new_state =
      state
      |> Map.replace!(:greeting, true)
      |> Map.replace!(:visits, state.visits + 1)

    hello_message(new_state)
    log_distance(value)
    set_greeting_reset()

    {:noreply, new_state}
  end

  @impl true
  def handle_info({_pin, :changed, %{value: value}}, state) do
    log_distance(value)
    {:noreply, state}
  end

  @impl true
  def handle_info(:reset_greeting, state) do
    waiting_message()
    {:noreply, %{state | greeting: false}}
  end

  @impl true
  def handle_info(_message, state) do
    {:noreply, state}
  end

  ## Helpers

  defp hello_message(state) do
    RGBLCD.set_text("Hello! You are")
    RGBLCD.set_cursor(1, 0)
    RGBLCD.write_text("visitor #" <> Integer.to_string(state.visits))
  end

  defp log_distance(value) do
    distance = ultrasonic_distance(value)
    Logger.info(distance)
  end

  defp set_greeting_reset() do
    Process.send_after(self(), :reset_greeting, @five_seconds)
  end

  defp ultrasonic_distance(value) when is_integer(value) do
    Integer.to_string(value) <> " cm away"
  end

  defp waiting_message() do
    RGBLCD.set_text("Waiting for a")
    RGBLCD.set_cursor(1, 0)
    RGBLCD.write_text("visitor!")
  end
end
