defmodule Syms.World do
    use Agent, restart: :temporary

    @moduledoc """
    a world is a map of locations where each 
    location is indexed by its unique {x, y, z} coordinates

    """

    @default_size 5
    @default_dimensions {@default_size, @default_size, @default_size}

    ## Public API
                         
    @doc """
    Starts a new world.
    """
    def start_link(options \\ []) do
        Agent.start_link(fn -> 
            options
            |> configure
            |> build
            |> IO.inspect
        end)
    end

    @doc """
    Gets a location from the `world` by `coordinates`.
            where `coordinates` is a `key` created from the 
            locations x, y, z coordinates
    """
    def get(world, coordinates) do
        Agent.get(world, &Map.get(&1, coordinates))
    end

    @doc """
    attempts to put a game object on a `location` 
    for the given `coordinates` in the `world`.
    """
    def put(world, coordinates, game_object) do
        current_location = get(world, coordinates)
        next_location = 
            case current_location do
                ## TODO: Some checks to make sure an object can be moved here
                [] ->
                    [game_object]
                [_] ->
                    [game_object] ++ current_location

            end
        Agent.update(world, &Map.put(&1, coordinates, next_location))
    end

    def delete(world, coordinates) do
        Agent.get_and_update(world, fn dict ->
          Map.pop(dict, coordinates)
        end)
    end

    ## Private functions

    ## merge defaults and options
    defp configure(options) do
        ## Defaults
        [ dimensions: @default_dimensions ]
            |> Keyword.merge(options) 
            |> Enum.into(%{})

    end

    ## build a map of indexed-by-coordinate locations 
    ## length*width*hight in size
    defp build(%{dimensions: {length, width, height}}) do
        Enum.map([length, width, height], fn n -> 0..n end)
        |> create_matrix
        |> Enum.map(&Syms.World.Location.from_task(&1))
        |> Map.new
    end

    @doc """
    returns a list of tasks
    """
    def create_matrix([length, width, height]) do
        Enum.map(length, fn l ->
        Enum.map(width, fn w -> 
        Enum.map(height, fn h ->
            Syms.World.Location.create({l, w, h})
        end)
        end)
        end)
        |> List.flatten
        |> Task.yield_many
    end

    defp enum(range, work) do
        Enum.map(range, &work(&1))
    end

end