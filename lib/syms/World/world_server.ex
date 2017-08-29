defmodule Syms.World.Server do
    def init(:ok) do
        {:ok, %Syms.World{}}
    end

    def handle_call({:get_location, coordinates}, _from, state) do
        coords = Syms.World.Location.hash_coords(coordinates)
        location = Map.get(state.locations, coords)
        {:reply, location, state}
    end

    def handle_call({:update_location, coordinates, location}, _from, state) do
        coords = Syms.World.Location.hash_coords(coordinates)
        next_locations = Map.put(state.locations, coords, location)
        next_world = %Syms.World{state| locations: next_locations}
        {:reply, :ok, next_world}
    end

    def handle_cast({:view}, state) do
        IO.inspect(state)
        {:noreply, state}
    end

    def handle_cast({:generate, dimensions}, state) do
        {l, w, h} = dimensions
        IO.puts "Generating world with dimensions: #{l} length by #{w} width by #{h} height"
        generate_locations(dimensions)
        {:noreply, %Syms.World{state | dimensions: dimensions}}
    end

    def handle_cast(msg, state) do
        IO.puts "Unknown cast sent to world"
        IO.inspect msg
        {:noreply, state}
    end

    def handle_info({:locations_generated, locations, time}, state) do
        IO.puts "World generated in: #{time / 1000} seconds " 
        {:noreply, %Syms.World{state | locations: locations}}
    end

    @doc """
    run a function on every combination of coordinates in a 3d map
    returns a %Map{}
    """
    def process_locations({length, width, height}, process) do
        for l <- 0..length,
            w <- 0..width,
            h <- 0..height,
            into: %{},
            do: process.({l, w, h})
    end
    ## Private functions

    @doc """
    use a task to generate a 3D matrix of l*w*h dimensions
    """
    def generate_locations(dimensions) do
        parent = self()
        start_time = Time.utc_now()
        Task.start(fn -> 
            locations = process_locations(dimensions, fn coords ->
                Syms.World.Location.create(coords)
            end)
            gen_time = Time.diff(Time.utc_now(), start_time, :millisecond)
            send(parent, {:locations_generated, locations, gen_time})
        end)
    end


end