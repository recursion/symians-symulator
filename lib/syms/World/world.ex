defmodule Syms.World do
    use GenServer

    defstruct dimensions: {0, 0, 0}, locations: %{}

    @moduledoc """
    a world is a %Map{} of locations keyed by coordinates
    """
                         
    @doc """
    Creates an empty world
    """
    def start_link(options \\ []) do
        GenServer.start_link(Syms.World.Server, :ok, options)
    end

    @doc """
    generate a world of size dimensions
    """
    def generate(world, dimensions) do
        GenServer.cast(world, {:generate, dimensions})
    end

    @doc """
    returns the locations stored in the key `coordinates`
    """
    def get_location(world, coordinates) do
        GenServer.call(world, {:get_location, coordinates})
    end

    @doc """
    put object at the location at coordinates
    """
    def put(world, coordinates, game_object) do
        current_location = get_location(world, coordinates)
        next_location = 
            case current_location do
                ## TODO: Some checks to make sure an object can be moved here
                nil -> []
                [] ->
                    [game_object]
                [_] ->
                    [game_object] ++ current_location

            end
        GenServer.call(world, {:update_location, coordinates, next_location})
    end

    ## view the model - used for debugging
    def view(world) do
        GenServer.cast(world, {:view})
    end

end