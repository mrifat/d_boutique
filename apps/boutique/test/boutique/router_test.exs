defmodule Boutique.RouterTest do
  use ExUnit.Case

  alias Boutique.Router

  setup_all do
    current = Application.get_env(:boutique, :routing_table)

    cluster_id = Application.get_env(:boutique, :cluster_id)

    Application.put_env(:boutique, :routing_table, [
      {?h..?n, :"h-n@#{cluster_id}"},
      {?v..?z, :"v-z@#{cluster_id}"}
    ])

    on_exit(fn ->
      Application.put_env(:boutique, :routing_table, current)
    end)

    %{cluster_id: cluster_id}
  end

  @tag :distributed
  test "routes requests across nodes", %{cluster_id: cluster_id} do
    inspect(Application.get_env(:boutique, :routing_table))
    assert Router.route("hello", Kernel, :node, []) == :"h-n@#{cluster_id}"
    assert Router.route("world", Kernel, :node, []) == :"v-z@#{cluster_id}"
  end

  test "raises on unknown routes" do
    assert_raise RuntimeError, ~r/could not find bucket/, fn ->
      Router.route(<<0>>, Kernel, :nodes, [])
    end
  end
end
