defmodule Syms.World.Server do
  require Logger

  alias Syms.World.Coordinates

  @moduledoc """
  genserver for managing a world's state
  """


  def init(options) do
    name = Keyword.fetch!(options, :name)
    :ets.new(:"#{name}", [:named_table])
    {:ok, %Syms.World{name: name}}
  end

  ## Synchronous Calls

  def handle_call({:put, coordinates, location}, _from, state) do
    :ets.insert(:"#{state.name}", {coordinates, location})
    {:reply, :ok, state}
  end

  def handle_call({:get, coordinates}, _from, state) do
      case :ets.lookup(:"#{state.name}", coordinates) do
        [] ->
          {:reply, nil, state}
        [{_key, location}] ->
          {:reply, location, state}
      end
  end

  def handle_call({:view}, _from, state) do
    # use World.map to generate coordinates and look them up from :ets
    case state.dimensions do
      {0, 0, 0} ->
        {:reply, state, state}
      _ ->
        locations = Syms.World.map(state.dimensions, fn loc ->
          [{_k, location}] = :ets.lookup(:"#{state.name}", loc)
          {Syms.World.Coordinates.to_string(loc), location}
        end)
        {:reply, %Syms.World{state | locations: locations}, state}
      end
  end

  ## Asynchronous Casts

  def handle_cast({:generate, {l, w, h} = dimensions}, state) do
    Logger.info fn ->
      "Creating world with dimensions of #{l}*#{w}*#{h}"
    end
    Syms.World.generate_locations(dimensions, self())
    {:noreply, %Syms.World{state | dimensions: dimensions}}
  end

  def handle_cast(msg, state) do
    Logger.warn fn ->
      "Unknown cast msg sent to world #{inspect msg}"
    end
    {:noreply, state}
  end

  ## Handle Info functions

  def handle_info({:location_generated, coords}, state) do
    :ets.insert(:"#{state.name}", {coords, %Syms.World.Location{}})
    {:noreply, state}
  end

  def handle_info({:locations_generated, dimensions, locations, time}, state) do
    Logger.info fn ->
      "World generated in: #{time / 1000} seconds"
    end
    {:noreply, %Syms.World{state | dimensions: dimensions, locations: locations}}
  end
end
