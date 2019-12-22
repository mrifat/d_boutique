defmodule BoutiqueServer.CommandTest do
  use ExUnit.Case, async: true
  doctest BoutiqueServer.Command

  @moduletag :distributed

  setup context do
    _registry = start_supervised!({Boutique.Registry, name: context.test})
    %{registry: context.test}
  end

  describe "run/2" do
    test "creates a bucket", %{registry: registry} do
      command = {:create, "shopping"}
      assert {:ok, "OK\r\n"} == BoutiqueServer.Command.run(command, registry)
    end

    test "inserts value in the bucket", %{registry: registry} do
      {:ok, _} = BoutiqueServer.Command.run({:create, "shopping"}, registry)
      command = {:put, "shopping", "milk", "1"}
      assert {:ok, "OK\r\n"} == BoutiqueServer.Command.run(command, registry)
    end

    test "returns value from the bucket", %{registry: registry} do
      {:ok, _} = BoutiqueServer.Command.run({:create, "shopping"}, registry)
      {:ok, _} = BoutiqueServer.Command.run({:put, "shopping", "milk", "1"}, registry)
      command = {:get, "shopping", "milk"}
      assert {:ok, "1\r\nOK\r\n"} == BoutiqueServer.Command.run(command, registry)
    end

    test "deletes a key from the bucket", %{registry: registry} do
      {:ok, _} = BoutiqueServer.Command.run({:create, "shopping"}, registry)
      {:ok, _} = BoutiqueServer.Command.run({:put, "shopping", "milk", "1"}, registry)
      command = {:delete, "shopping", "milk"}
      assert {:ok, "OK\r\n"} == BoutiqueServer.Command.run(command, registry)
    end
  end
end
