defmodule Syms.World.Server do
  require Logger
  use GenServer, restart: :temporary

  alias Syms.World.Coordinates

  @moduledoc """
  genserver for managing a world's state
  """

  ## Public API

  @doc """
  Creates a named, empty world
  the worlds name will eventually be used for its :ets table name
  args is currently only used from tests that use start_supervised
  when start_supervised is called, name comes in as an atom is args
  otherwise the name comes in under name
  """
  def start_link(args, name \\ "") do
    name = if is_atom args do
        Atom.to_string args
      else
        name
      end
    GenServer.start_link(__MODULE__, [name: name], [])
  end

  @doc """
  generate a map of locations sized from dimensions`
  """
  def generate(world, dimensions) do
    GenServer.cast(world, {:generate, dimensions})
  end

  @doc """
  return the world struct
  """
  def view(world) do
    GenServer.call(world, {:view})
  end

  @doc """
  returns the location stored in the key `coordinates`
  """
  def get(world, coordinates) do
    GenServer.call(world, {:get, coordinates})
  end

  @doc """
  put a location at coordinates
  """
  def put(world, coordinates, location = %Syms.World.Location{}) do
    GenServer.call(world, {:put, coordinates, location})
  end

  ## Server Functions

  def init(options \\ []) do
    name = Keyword.fetch!(options, :name)
    {:ok, %Syms.World{name: name}}
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
