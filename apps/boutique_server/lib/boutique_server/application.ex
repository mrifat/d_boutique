defmodule BoutiqueServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: BoutiqueServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> BoutiqueServer.accept(port()) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BoutiqueServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    (Application.get_env(:boutique, :port) || "4040")
    |> String.to_integer()
  end
end
