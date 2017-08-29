defmodule Syms.WorldTest do
    use ExUnit.Case, async: true
    describe "when initialized:" do 
        setup do
            {:ok, world} = start_supervised(Syms.World)
            %{world: world}
        end

        test "has dimensions of {0, 0, 0}", %{world: world} do
            wv = Syms.World.view(world)
            assert wv == %Syms.World{}
            assert wv.dimensions == {0, 0, 0}
        end

        test "has an empty locations %Map{}", %{world: world} do
            wv = Syms.World.view(world)
            assert wv == %Syms.World{}
            assert wv.locations == %{}
        end

        test "view: returns a %Syms.World{} struct", %{world: world} do
            assert Syms.World.view(world) == %Syms.World{}
        end
    end

    describe "when locations have been generated:" do
        setup do
            {:ok, world} = start_supervised(Syms.World)
            Syms.World.create(world, {5, 5, 5})
            Process.sleep(25)
            %{world: world}
        end

        test "locations exist for all coordinates", %{world: world} do
            assert Syms.World.view(world).dimensions == {5, 5, 5}
            for l <- 0..5, w <- 0..5, h <- 0..5 do
                assert Syms.World.view(world).locations["#{l}#{w}#{h}"] == []
            end
        end

        test "view: returns a populated %Syms.World{} struct", %{world: world} do
            subject = Syms.World.view(world)
            assert length(Map.to_list(subject.locations)) == 216
        end

        test "get: gets location at coordinates", %{world: world} do 
            assert Syms.World.get(world, {0, 0, 0}) == []
        end

        test "put: puts an object on the location at coordinates", %{world: world} do 
            assert Syms.World.get(world, {0, 0, 0}) == []
            Syms.World.put(world, {0, 0, 0}, "hi!")
            assert Syms.World.get(world, {0, 0, 0}) == ["hi!"]
        end
    end
  end