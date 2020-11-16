defmodule HAPDemo.GPIO do
  @moduledoc """
  Responsible for controlling indicated GPIO pins
  """

  @behaviour HAP.ValueStore

  use GenServer

  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl HAP.ValueStore
  def get_value(opts) do
    GenServer.call(__MODULE__, {:get, opts})
  end

  @impl HAP.ValueStore
  def put_value(value, opts) do
    GenServer.call(__MODULE__, {:put, value, opts})
  end

  @impl GenServer
  def init(_) do
    {:ok, gpio} = Circuits.GPIO.open(22, :output)
    {:ok, %{22 => gpio}}
  end

  @impl GenServer
  def handle_call({:get, gpio_pin: gpio}, _from, state) do
    value =
      state
      |> Map.get(gpio)
      |> Circuits.GPIO.read()

    Logger.info("Returning value of #{value} for GPIO #{gpio}")

    {:reply, {:ok, value}, state}
  end

  @impl GenServer
  def handle_call({:put, value, gpio_pin: gpio}, _from, state) do
    result =
      state
      |> Map.get(gpio)
      |> Circuits.GPIO.write(value)

    Logger.info("Writing value of #{value} to GPIO #{gpio} (result #{result})")

    {:reply, result, state}
  end
end
