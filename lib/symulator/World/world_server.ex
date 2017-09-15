defmodule Symulator.World.Server do
  require Logger
  alias Symulator.World

  @moduledoc """
  genserver for managing a world's state
  TODO: it may be better to only store state required for running the world server in the GenServers state
  and just use the %Symulator.World{} struct for returning the world data to clients (since most critical world data is now stored in :ets)
  """

  @doc """
  extract the world name from options and create an ets table for this world
  """
  def init(options) do
    name = Keyword.fetch!(options, :name)
    :ets.new(String.to_atom(name), [:named_table])
    {:ok, %Symulator.World{name: name}}
  end

  # Synchronous Calls

  def handle_call({:put, coordinates, location}, _from, state) do
    case ets_lookup(state.name, "locations") do
      [] ->
        next_locations = {"locations", %{coordinates => location}}
        ets_insert(state.name, next_locations)
        {:reply, :ok, state}
      [{_key, locations}] ->
        next_locations = {"locations", Map.put(locations, coordinates, location)}
        ets_insert(state.name, next_locations)
        {:reply, :ok, state}
      end
  end

  def handle_call({:get, coordinates}, _from, state) do
      case ets_lookup(state.name, "locations") do
        [] ->
          {:reply, nil, state}
        [{_key, locations}] ->
          {:reply, locations[coordinates], state}
      end
  end

  def handle_call({:get}, _from, state) do
    # use World.map to generate coordinates and look them up from :ets
    case state.dimensions do
      {0, 0, 0} ->
        {:reply, state, state}
      _ ->
        [{_k, locations}] = ets_lookup(state.name, "locations")
        {:reply, %Symulator.World{state | locations: locations}, state}
      end
  end

  # Asynchronous Casts

  def handle_cast({:generate, {l, w, h} = dimensions}, state) do
    Logger.info fn ->
      "Creating world with dimensions of #{l}*#{w}*#{h}"
    end
    World.generate_locations(dimensions, self(), Time.utc_now())
    ets_insert(state.name, {"dimensions", dimensions})
    {:noreply, %Symulator.World{state | dimensions: dimensions}}
  end

  def handle_cast(msg, state) do
    Logger.warn fn ->
      "Unknown cast msg sent to world #{inspect msg}"
    end
    {:noreply, state}
  end

  # Handle Info functions

  def handle_info({:location_generated, coords}, state) do
    ets_insert(state.name, {coords, %Symulator.World.Location{}})
    {:noreply, state}
  end

  def handle_info({:locations_generated, locations, time}, state) do
    Logger.info fn ->
      "World generated in: #{time / 1000} seconds"
    end
    ets_insert(state.name, {"locations", locations})
    {:noreply, state}
  end

  # insert value into the :ets table world_name
  def ets_insert(world_name, value) do
    :ets.insert(String.to_atom(world_name), value)
  end

  def ets_lookup(world_name, key) do
    :ets.lookup(String.to_atom(world_name), key)
  end
end
