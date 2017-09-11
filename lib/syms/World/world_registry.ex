defmodule Syms.World.Registry do
  use GenServer

  @moduledoc """
  World Registry
  - creates / monitors world servers by name
  - returns the PID of existing world servers
  """

  ## Client API

  @doc """
  Starts a registry genserver
  """
  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end


  @doc """
  Looks up the world pid for `name` stored in `server`.
  Returns `{:ok, pid}` if the world exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  creates a world associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server callbacks

  def init(_registry_name) do
    # worlds = :ets.new(table, [:named_table, read_concurrency: true])
    worlds = %{}
    refs  = %{}
    {:ok, {worlds, refs}}
  end

  def handle_call({:lookup, name}, _from, {worlds, refs}) do
      {:reply, Map.fetch(worlds, name), {worlds, refs}}
  end

  # create a new world server or return :noop message if one
  # already exists using that name
  def handle_call({:create, name}, _from, {worlds, refs}) do
     if Map.has_key?(worlds, name) do
        {:reply, {:noop, :already_exists}, {worlds, refs}}
      else
        {:ok, pid} = Syms.World.Supervisor.start_world(name)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        # :ets.insert(worlds, {name, pid})
        worlds = Map.put(worlds, name, pid)
        {:reply, pid, {worlds, refs}}
      end
  end

  # handle a world server process going down
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {worlds, refs}) do
    {world, refs} = Map.pop(refs, ref)
    worlds = Map.delete(worlds, world)
    {:noreply, {worlds, refs}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
