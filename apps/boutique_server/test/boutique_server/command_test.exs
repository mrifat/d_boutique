defmodule BoutiqueServer.CommandTest do
  use ExUnit.Case, async: true
  doctest BoutiqueServer.Command

  @moduletag :distributed

  setup_all do
    current = Application.get_env(:boutique, :routing_table)

    cluster_id = Application.get_env(:boutique, :cluster_id)

    Application.put_env(:boutique, :routing_table, [
      {?o..?u, :"h-n@#{cluster_id}"},
      {?v..?z, :"v-z@#{cluster_id}"}
    ])

    on_exit(fn ->
      Application.put_env(:boutique, :routing_table, current)
    end)
  end

  setup context do
    _registry = start_supervised!({Boutique.Registry, name: context.test})
    :ok
  end

  describe "run/2" do
    test "creates a bucket" do
      command = {:create, "shopping"}
      assert {:ok, "OK\r\n"} == BoutiqueServer.Command.run(command)
    end

    test "inserts value in the bucket" do
      {:ok, _} = BoutiqueServer.Command.run({:create, "shopping"})
      command = {:put, "shopping", "milk", "1"}
      assert {:ok, "OK\r\n"} == BoutiqueServer.Command.run(command)
    end

    test "returns value from the bucket" do
      {:ok, _} = BoutiqueServer.Command.run({:create, "shopping"})
      {:ok, _} = BoutiqueServer.Command.run({:put, "shopping", "milk", "1"})
      command = {:get, "shopping", "milk"}
      assert {:ok, "1\r\nOK\r\n"} == BoutiqueServer.Command.run(command)
    end

    test "deletes a key from the bucket" do
      {:ok, _} = BoutiqueServer.Command.run({:create, "shopping"})
      {:ok, _} = BoutiqueServer.Command.run({:put, "shopping", "milk", "1"})
      command = {:delete, "shopping", "milk"}
      assert {:ok, "OK\r\n"} == BoutiqueServer.Command.run(command)
    end
  end
end
