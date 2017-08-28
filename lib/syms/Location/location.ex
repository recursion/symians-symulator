defmodule Syms.World.Location do
    @moduledoc """
        a location is a data structure that has coordinates
        and has a queue for storing items/game objects
    """

    @location []

    @doc """
        create a location: a key, value pair where the key is
    """
    def create({x, y, z} = _coordinates) do
        [{:"#{x}#{y}#{z}", @location}]
    end


    @doc """
    returns a list of locations from a list of tasks
    """
    def from_tasks(tasks) do
        tasks
        |> Enum.map(&from_task(&1))
        |> List.flatten
    end


    @doc """
    parses a task result and
    returns the location information
    """
    def from_task({_task, {:ok, location}}) do
        location
    end

end