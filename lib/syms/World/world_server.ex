defmodule Syms.World.Server do
  require Logger
  alias Syms.World.{Location, Coordinates}

  @moduledoc """
  World Server - manages world state
  """
  def init(:ok) do
    {:ok, %Syms.World{}}
  end

  ## Synchronous Calls

  def handle_call({:put, coordinates, location}, _from, state) do
    coords = Coordinates.to_string(coordinates)
    next_locations = Map.put(state.locations, coords, location)
    next_world = %Syms.World{state| locations: next_locations}
    {:reply, :ok, next_world}
  end

  def handle_call({:get, coordinates}, _from, state) do
    coords = Coordinates.to_string(coordinates)
    location = Map.get(state.locations, coords)
    {:reply, location, state}
  end

  def handle_call({:view}, _from, state) do
    {:reply, state, state}
  end

  ## Asynchronous Casts

  def handle_cast({:generate, dimensions}, state) do
    {l, w, h} = dimensions
    Logger.info fn ->
      "Creating world with dimensions of #{l}*#{w}*#{h}"
    end
    generate_locations_async(dimensions, self(), Time.utc_now())
    {:noreply, state}
  end

  def handle_cast(msg, state) do
    Logger.warn fn ->
      "Unknown cast msg sent to world #{inspect msg}"
    end
    {:noreply, state}
  end

  def handle_info({:locations_generated, dimensions, locations, time}, state) do
    Logger.info fn ->
      "World generated in: #{time / 1000} seconds"
    end
    {:noreply, %Syms.World{state | dimensions: dimensions, locations: locations}}
  end

  @doc """
  run a function on every combination of coordinates in the world
  returns a %Map{}
  """
  def process({length, width, height}, process) do
    for l <- 0..length,
      w <- 0..width,
      h <- 0..height,
      into: %{},
      do: process.({l, w, h})
  end

  ## Private functions

  def generate_locations(dimensions) do
    process(dimensions, fn coords ->
      Location.create(coords)
    end)
  end

  @doc """
  use a task to generate a 3D matrix of l*w*h dimensions
  """
  def generate_locations_async(dimensions, parent, start_time) do
    Task.start(fn ->
      locations = generate_locations(dimensions)
      gen_time = Time.diff(Time.utc_now(), start_time, :millisecond)
      send(parent, {:locations_generated, dimensions, locations, gen_time})
    end)
  end
end
