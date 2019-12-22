defmodule Boutique.Bucket do
  @moduledoc """
  This module is a simple server implementation aimed at
  retrieving and updating the state of a bucket.
  """
  use Agent, restart: :temporary

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  @spec get(pid(), String.t()) :: nil | any()
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  @spec put(pid(), String.t(), any()) :: :ok
  def put(bucket, key, value) do
    Agent.update(bucket, fn state ->
      Map.put(state, key, value)
    end)
  end

  @doc """
  Deletes `key` from `bucket`.
  """
  @spec delete(pid(), String.t()) :: any()
  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn dict ->
      Map.pop(dict, key)
    end)
  end
end
