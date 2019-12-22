defmodule Boutique do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Boutique.Supervisor.start_link(name: Boutique.Supervisor)
  end
end
