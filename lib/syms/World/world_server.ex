defmodule Syms.World.Server do
    @moduledoc """
    world server api and helpers
    """
    def init(:ok) do
        {:ok, %Syms.World{}}
    end

    ## Calls

    def handle_call({:update_location, coordinates, location}, _from, state) do
        coords = Syms.World.Coordinates.to_string(coordinates)
        next_locations = Map.put(state.locations, coords, location)
        next_world = %Syms.World{state| locations: next_locations}
        {:reply, :ok, next_world}
    end

    def handle_call({:get, coordinates}, _from, state) do
        coords = Syms.World.Coordinates.to_string(coordinates)
        location = Map.get(state.locations, coords)
        {:reply, location, state}
    end

    def handle_call({:view}, _from, state) do
        {:reply, state, state}
    end

    ## Casts

    def handle_cast({:create, dimensions}, state) do
        # {l, w, h} = dimensions
        # IO.puts "Creating world with dimensions of #{l}*#{w}*#{h}"
        generate_locations_async(dimensions, self(), Time.utc_now())
        {:noreply, state}
    end

    def handle_cast(msg, state) do
        IO.puts "Unknown cast sent to world"
        IO.inspect msg
        {:noreply, state}
    end

    def handle_info({:locations_generated, dimensions, locations, _time}, state) do
        # IO.puts "World generated in: #{time / 1000} seconds " 
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
            Syms.World.Location.create(coords)
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