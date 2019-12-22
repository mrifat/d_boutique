defmodule Boutique.RouterTest do
  use ExUnit.Case, async: true

  alias Boutique.Router

  @tag :distributed

  test "routes requests across nodes" do
    assert Router.route("hello", Kernel, :node, []) == :"h-n@#{cluster_id()}"
    assert Router.route("world", Kernel, :node, []) == :"v-z@#{cluster_id()}"
  end

  test "raises on unknown routes" do
    assert_raise RuntimeError, ~r/could not find bucket/, fn ->
      Router.route(<<0>>, Kernel, :nodes, [])
    end
  end

  defp cluster_id do
    Application.get_env(:boutique, :cluster_id)
  end
end
