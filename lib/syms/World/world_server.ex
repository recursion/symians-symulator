defmodule Syms.World.Server do
  require Logger

  alias Syms.World.Coordinates

  @moduledoc """
  genserver for managing a world's state
  """


  def init(options) do
    name = Keyword.fetch!(options, :name)
    # create the ets table here
    {:ok, %Syms.World{name: name}}
  end
  
  ## Synchronous Calls

  def handle_call({:put, coordinates, location}, _from, state) do
    # do an :ets lookup instead
    coords = Coordinates.to_string(coordinates)
    next_locations = Map.put(state.locations, coords, location)
    next_world = %Syms.World{state| locations: next_locations}
    {:reply, :ok, next_world}
  end

  def handle_call({:get, coordinates}, _from, state) do
    # do an :ets lookup instead
    coords = Coordinates.to_string(coordinates)
    location = Map.get(state.locations, coords)
    {:reply, location, state}
  end

  def handle_call({:view}, _from, state) do
    # use World.map to generate coordinates and look them up from :ets
    {:reply, state, state}
  end

  ## Asynchronous Casts

  def handle_cast({:generate, {l, w, h} = dimensions}, state) do
    Logger.info fn ->
      "Creating world with dimensions of #{l}*#{w}*#{h}"
    end
    Syms.World.generate_locations(dimensions, self(), Time.utc_now())
    {:noreply, state}
  end

  def handle_cast(msg, state) do
    Logger.warn fn ->
      "Unknown cast msg sent to world #{inspect msg}"
    end
    {:noreply, state}
  end

  ## Handle Info functions

  def handle_info({:locations_generated, dimensions, locations, time}, state) do
    Logger.info fn ->
      "World generated in: #{time / 1000} seconds"
    end
    {:noreply, %Syms.World{state | dimensions: dimensions, locations: locations}}
  end
end
