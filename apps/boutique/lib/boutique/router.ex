defmodule Boutique.Router do
  @moduledoc """
  This module is responsible for dispatching requests
  to the appropriate `node` in the system using the
  `Boutique.RouterTasks` supervisor.

  Each dispatch occurs by a supervised process in an
  asynchronous manner on distributed nodes optimizing for faster look-ups.

  To find nodes in the cluster we have a routing table that uses
  the first byte of `bucket` names to find the `node`
  responsible for doing the data store lookup and retrieve the
  value.
  """

  @doc """
  Finds the right node to dispatch the request to.
  """
  @spec route(binary(), term(), atom(), list()) :: any()
  def route(bucket, mod, fun, args) do
    with first_byte <- :binary.first(bucket),
         nil <- get_route(first_byte) do
      no_entry_error(bucket)
    else
      {_range, node_name} ->
        dispatch(node_name, [bucket, mod, fun, args])
    end
  end

  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  @spec dispatch(String.t(), [...]) :: any()
  def dispatch(node, [_bucket, mod, fun, args]) when node == node(), do: apply(mod, fun, args)

  def dispatch(node, args) do
    {Boutique.RouterTasks, node}
    |> Task.Supervisor.async(__MODULE__, :route, args)
    |> Task.await()
  end

  # Gets the node to route the request to
  @spec get_route(byte()) :: {any(), String.t()} | nil
  defp get_route(first_byte) do
    routing_table()
    |> Enum.find(fn {enum, _node} ->
      first_byte in enum
    end)
  end

  @spec no_entry_error(String.t()) :: none()
  defp no_entry_error(bucket) do
    raise "could not find bucket with name #{inspect(bucket)} " <>
            "in table #{inspect(routing_table())}"
  end

  # @spec routing_table() :: [{%Range{}, atom()}, ...]
  defp routing_table do
    Application.fetch_env!(:boutique, :routing_table)
  end
end
