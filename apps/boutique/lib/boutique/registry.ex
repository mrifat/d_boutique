defmodule Boutique.Registry do
  @moduledoc """
  The Registry is a process that is responsible for
  managing the data stores, making sure it's always up
  and preserving the state of the data stores.
  """
  use GenServer

  @doc """
  Starts the registry with the given options.

  `:name` is always required.
  """
  def start_link(opts) do
    bucket = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, bucket, opts)
  end

  @doc """
  Looks up the pid for `name` stored in `bucket`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  @spec lookup(atom() | :ets.tid(), String.t()) :: :error | {:ok, pid()}
  def lookup(bucket, name) do
    case :ets.lookup(bucket, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a `bucket` associated with the given `name` in `bucket`.
  """
  @spec create(pid() | term(), String.t()) :: any()
  def create(bucket, name) do
    GenServer.call(bucket, {:create, name})
  end

  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}

      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(Boutique.BucketSupervisor, Boutique.Bucket)

        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)

        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
