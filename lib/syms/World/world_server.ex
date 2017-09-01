defmodule Syms.World.Server do
  require Logger
  alias Syms.World

  @moduledoc """
  genserver for managing a world's state
  TODO: it may be better to only store state required for running the world server in the GenServers state
  and just use the %Syms.World{} struct for returning the world data to clients (since most critical world data is now stored in :ets)
  """

  def init(options) do
    name = Keyword.fetch!(options, :name)
    :ets.new(String.to_atom(name), [:named_table])
    {:ok, %Syms.World{name: name}}
  end

  # Synchronous Calls

  def handle_call({:put, coordinates, location}, _from, state) do
    case :ets.lookup(String.to_atom(state.name), "locations") do
      [] ->
        next_locations = {"locations", %{coordinates => location}}
        :ets.insert(String.to_atom(state.name), next_locations)
        {:reply, :ok, state}
      [{_key, locations}] ->
        next_locations = {"locations", Map.put(locations, coordinates, location)}
        :ets.insert(String.to_atom(state.name), next_locations)
        {:reply, :ok, state}
      end
  end

  def handle_call({:get, coordinates}, _from, state) do
      case :ets.lookup(String.to_atom(state.name), "locations") do
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
        [{_k, locations}] = :ets.lookup(String.to_atom(state.name), "locations")
        {:reply, %Syms.World{state | locations: locations}, state}
      end
  end

  # Asynchronous Casts

  def handle_cast({:generate, {l, w, h} = dimensions}, state) do
    Logger.info fn ->
      "Creating world with dimensions of #{l}*#{w}*#{h}"
    end
    World.generate_locations(dimensions, self(), Time.utc_now())
    :ets.insert(String.to_atom(state.name), {"dimensions", dimensions})
    {:noreply, %Syms.World{state | dimensions: dimensions}}
  end

  def handle_cast(msg, state) do
    Logger.warn fn ->
      "Unknown cast msg sent to world #{inspect msg}"
    end
    {:noreply, state}
  end

  # Handle Info functions

  def handle_info({:location_generated, coords}, state) do
    :ets.insert(String.to_atom(state.name), {coords, %Syms.World.Location{}})
    {:noreply, state}
  end

  def handle_info({:locations_generated, dimensions, locations, time}, state) do
    Logger.info fn ->
      "World generated in: #{time / 1000} seconds"
    end
    :ets.insert(String.to_atom(state.name), {"locations", locations})
    {:noreply, %Syms.World{state | dimensions: dimensions,
                                   locations: locations}}
  end
end
