defmodule Syms.World.Location do
    @moduledoc """
        a location is a data structure that has coordinates
        and has a queue for storing items/game objects
    """
    @location []

    @doc """
        location: a key, value pair 
        where the key is a set of coordinates as a string
        and the value is a location - currently a simple list
    """
    def create(coordinates) do
        {hash_coords(coordinates), @location}
    end

    def hash_coords({x, y, z}) do
        "#{x}#{y}#{z}"
    end

    def put(location, _game_object) do
        IO.inspect(location)
    end

    @doc """
    returns a list of locations from a list of tasks
    """
    def list_from_tasks(tasks) do
        tasks
        |> Enum.map(&from_task(&1))
        |> List.flatten
    end

    # destructure a task and return the location data
    defp from_task({_task, {:ok, location}}) do
        location
    end
end