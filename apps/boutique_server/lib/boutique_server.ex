defmodule BoutiqueServer do
  @moduledoc """
  A TCP Server.
  Listens to a port until the port is available and get hold of the socket.
  Waits for a client connection on that port and accepts it.
  Reads the client request and writes a response back.
  """

  require Logger

  @doc """
  Accepts a port connection on TCP.
  `:binary` - receives data as binaries instead of lists.
  `packet: :line` - receives data line by line.
  `active: false` - blocks on `:gen_tcp.recv/2` until data is available.
  `reuseaddr: true` - allows us to reuse the address if the listener crashes.
  """
  @spec accept(char()) :: no_return()
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  @spec loop_acceptor(port()) :: no_return()
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(BoutiqueServer.TaskSupervisor, fn ->
        serve(client)
      end)

    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  @spec serve(port()) :: no_return()
  defp serve(socket) do
    message =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- BoutiqueServer.Command.parse(data),
           do: BoutiqueServer.Command.run(command)

    write_line(socket, message)
    serve(socket)
  end

  @spec read_line(port()) :: {:error, atom} | {:ok, String.t()}
  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  @spec write_line(port(), {:error, :not_found | :not_implemented} | {:ok, String.t()}) ::
          :ok | {:error, atom()}
  defp write_line(socket, {:ok, message}) do
    :gen_tcp.send(socket, message)
  end

  defp write_line(socket, {:error, :not_implemented}) do
    :gen_tcp.send(socket, "COMMAND NOT IMPLEMENTED\r\n")
  end

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write_line(socket, {:error, :closed}) do
    Logger.info("Closing connection: #{inspect(socket)}")
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
