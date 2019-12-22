defmodule Boutique.BucketTest do
  use ExUnit.Case, async: true

  setup do
    bucket = start_supervised!(Boutique.Bucket)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    refute Boutique.Bucket.get(bucket, "milk")

    Boutique.Bucket.put(bucket, "milk", 3)
    assert Boutique.Bucket.get(bucket, "milk") == 3
  end

  test "delete a key from the bucket", %{bucket: bucket} do
    Boutique.Bucket.put(bucket, "milk", 1)

    assert Boutique.Bucket.delete(bucket, "milk")
    refute Boutique.Bucket.get(bucket, "milk")
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(Boutique.Bucket, []).restart == :temporary
  end
end
