defmodule Syms.World do
    use Agent, restart: :temporary

    @moduledoc """
    a world is a %Map{} of locations where each 
    location is indexed by its unique {x, y, z} coordinates
    """

    @default_size 5
    @default_dimensions {@default_size, @default_size, @default_size}

                         
    @doc """
    Starts a new world.
    """
    def start_link(options \\ []) do
        Agent.start_link(fn -> 
            options
            |> configure
            |> create
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

    defp configure(options) do
        ## Defaults
        [ dimensions: @default_dimensions ]
            |> Keyword.merge(options) 
            |> Enum.into(%{})

    end

    defp create(%{dimensions: {length, width, height}}) do
        [length, width, height]
        |> Enum.map(fn n -> 0..n end)
        |> create_matrix
        |> Task.yield_many
        |> Syms.World.Location.from_tasks
        |> Map.new
    end

    defp create_matrix([length, width, height]) do
        List.flatten Enum.map(length, fn l ->
          Enum.map(width, fn w -> 
            Enum.map(height, fn h ->
              Task.async(fn -> 
                Syms.World.Location.create({l, w, h})
              end)
            end)
          end)
        end)
    end
end