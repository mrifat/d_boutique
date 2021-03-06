defmodule BoutiqueServer.Command do
  @moduledoc """
  Generates commands from client requests.
  """

  alias Boutique.{Bucket, Registry, Router}

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> BoutiqueServer.Command.parse("CREATE shopping\r\n")
      {:ok, {:create, "shopping"}}

      iex> BoutiqueServer.Command.parse("CREATE shopping \r\n")
      {:ok, {:create, "shopping"}}

      iex> BoutiqueServer.Command.parse("PUT shopping milk 1\r\n")
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> BoutiqueServer.Command.parse("GET shopping milk\r\n")
      {:ok, {:get, "shopping", "milk"}}

      iex> BoutiqueServer.Command.parse("DELETE shopping eggs\r\n")
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the
  wrong number of arguments return an error:

      iex> BoutiqueServer.Command.parse("UNKNOWN shopping bananas 5\r\n")
      {:error, :not_implemented}

      iex> BoutiqueServer.Command.parse("GET shopping\r\n")
      {:error, :not_implemented}

  """
  @spec parse(String.t()) :: {:ok, {atom(), String.t()}} | {:error, :not_implemented}
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] ->
        {:ok, {:create, bucket}}

      ["GET", bucket, key] ->
        {:ok, {:get, bucket, key}}

      ["PUT", bucket, key, value] ->
        {:ok, {:put, bucket, key, value}}

      ["DELETE", bucket, key] ->
        {:ok, {:delete, bucket, key}}

      _else ->
        {:error, :not_implemented}
    end
  end

  @doc """
  Runs the given command.
  """
  @spec run(
          {:create, String.t()}
          | {:delete, String.t(), String.t()}
          | {:get, String.t(), String.t()}
          | {:put, String.t(), String.t(), binary() | number()}
        ) :: {:error, :not_found} | {:ok, String.t()}
  def run(command)

  def run({:create, bucket}) do
    Registry.create(Boutique.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      value = Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid ->
      Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid ->
      Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  @spec lookup(String.t(), (pid() -> {:ok, String.t()})) ::
          {:ok, String.t()} | {:error, :not_found}
  defp lookup(bucket, callback) do
    case Router.route(bucket, Registry, :lookup, [Registry, bucket]) do
      {:ok, pid} -> callback.(pid)
      _ -> {:error, :not_found}
    end
  end
end
