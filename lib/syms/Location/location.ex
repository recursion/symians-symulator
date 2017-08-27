defmodule Syms.World.Location do
    @location []

    @doc """
    creates an async.task that returns a location 
        {key, value} 
    """
    def create({x, y, z}) do
        Task.async(fn -> 
            {:"#{x}#{y}#{z}", @location}
        end)
    end


    @doc """
    parses a task result and
    returns the location information
    """
    def from_task({_task, {:ok, location}}) do
        location
    end
end