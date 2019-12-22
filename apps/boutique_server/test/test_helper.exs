excluded = if Node.alive?(), do: [], else: [distributed: true]
ExUnit.start(exclude: excluded)
