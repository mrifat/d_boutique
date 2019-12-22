defmodule Boutique.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Boutique.Registry, name: Boutique.Registry},
      {DynamicSupervisor, name: Boutique.BucketSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Boutique.RouterTasks}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
