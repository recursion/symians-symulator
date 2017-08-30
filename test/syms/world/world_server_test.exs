defmodule Syms.World.ServerTest do
  use ExUnit.Case, async: true
  alias Syms.World.Server, as: WorldServer

  @moduledoc """
  Tests the World Server
  """
  describe "put" do
    setup do
      {:ok, world} = start_supervised(Syms.World.Server)
      %{world: world}
    end
    test "throws an error if something other than a %Syms.World.Location is used as the third argument", %{world: world} do
      catch_error WorldServer.put(world, {0, 0, 0}, "pig")
    end
    test "accepts non default locations", %{world: world} do
      assert WorldServer.put(world, {0, 0, 0}, %Syms.World.Location{type: :grass})
    end
  end
  describe "when initialized" do
    setup do
      {:ok, world} = start_supervised(Syms.World.Server)
      %{world: world}
    end

    test "view returns a %Syms.World{} struct", %{world: world} do
      subject = WorldServer.view(world)
      assert subject == %Syms.World{}
    end

    test "get returns nil for any set of coordinates", %{world: world} do
      assert WorldServer.get(world, {0, 0, 0}) == nil
    end

    test "put puts a location at coordinates", %{world: world} do
      assert WorldServer.get(world, {0, 0, 0}) == nil
      WorldServer.put(world, {0, 0, 0}, %Syms.World.Location{})
      assert WorldServer.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end
  end

  describe "when generate completes" do
    setup do
      {:ok, world} = start_supervised(WorldServer)
      WorldServer.generate(world, {5, 5, 5})
      Process.sleep(25)
      %{world: world}
    end

    test "locations exist for all coordinates", %{world: world} do
      assert Syms.World.Server.view(world).dimensions == {5, 5, 5}
      for l <- 0..5, w <- 0..5, h <- 0..5 do
          assert WorldServer.view(world).locations["#{l}#{w}#{h}"] == %Syms.World.Location{}
      end
    end

    test "World.Server.view returns a dimensioned, locations-populated %Syms.World{} struct", %{world: world} do
      subject = WorldServer.view(world)
      assert length(Map.to_list(subject.locations)) == 216
    end

    test "World.Server.get returns the location at coordinates", %{world: world} do
      assert WorldServer.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end

    test "World.Server.put puts an object in/on location at coordinates", %{world: world} do
      WorldServer.put(world, {0, 0, 0}, %Syms.World.Location{})
      assert WorldServer.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end
  end
end
