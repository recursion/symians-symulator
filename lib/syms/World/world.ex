defmodule Syms.World do
    use GenServer
    alias Syms.World.{Location, Server}

    @moduledoc """
    a world is a %Map{} of locations keyed by coordinates
    `dimensions` is the length, width, and height of the world
    """
    defstruct dimensions: {0, 0, 0}, locations: %{}

    @doc """
    Creates an empty world
    """
    def start_link(options \\ []) do
        GenServer.start_link(Server, :ok, options)
    end

    @doc """
    generate a world from dimensions
    """
    def generate(world, dimensions) do
        GenServer.cast(world, {:generate, dimensions})
    end

    @doc """
    return the entire world
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
    put object at location coordinates
    """
    def put(world, coordinates, game_object) do
        current_location = get(world, coordinates)
        next_location = Location.put(current_location, game_object)
        GenServer.call(world, {:update_location, coordinates, next_location})
    end
end
