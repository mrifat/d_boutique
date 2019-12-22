defmodule Boutique.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _registry = start_supervised!({Boutique.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns bucket", %{registry: registry} do
    assert Boutique.Registry.lookup(registry, "does-not-exist") == :error

    Boutique.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Boutique.Registry.lookup(registry, "shopping")

    Boutique.Bucket.put(bucket, "milk", 1)
    assert Boutique.Bucket.get(bucket, "milk") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    Boutique.Registry.create(registry, "shopping")
    {:ok, bucket} = Boutique.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)

    _ = Boutique.Registry.create(registry, "bogus")
    assert Boutique.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Boutique.Registry.create(registry, "shopping")
    {:ok, bucket} = Boutique.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason.
    Agent.stop(bucket, :shutdown)

    _ = Boutique.Registry.create(registry, "bogus")
    assert Boutique.Registry.lookup(registry, "shopping") == :error
  end

  test "bucket can crash at any time", %{registry: registry} do
    Boutique.Registry.create(registry, "shopping")
    {:ok, bucket} = Boutique.Registry.lookup(registry, "shopping")

    Agent.stop(bucket, :shutdown)
    catch_exit(Boutique.Bucket.put(bucket, "milk", 3))
  end
end
