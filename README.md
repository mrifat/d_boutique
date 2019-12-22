# D-Boutique
D-Boutique is a distributed key value store built in Elixir, it uses Erlang's [built-in term storage](https://erlang.org/doc/man/ets.html).

D-Boutique was built as an attempt to understand how distributed systems works and to learn more about Elixir and Erlang ecosystem.

D-Boutique is an umbrella project consisting of two supervised applications.

## Getting Started
Setup your machine with Erlang <sub><sup>22.2</sup></sub> and Elixir <sub><sup>1.9.4</sup></sub>.

The easiest way to do that is to use a universal language version manager, i.e: [asdf](https://github.com/asdf-vm/asdf).

**OSX**
```shell
$> brew install asdf

$> echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.bash_profile
$> echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> ~/.bash_profile
```

Erlang

<sub><sup>_You may encounter an SSL error, in that case please refer to [asdf-erlang](https://github.com/asdf-vm/asdf-erlang) for possible solution._</sup></sub>
```shell
$> asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git

$> brew install autoconf
$> asdf install erlang 22.2
```

Elixir
```shell
$> asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
$> asdf install elixir 1.9.4
```

**Linux**

```shell
$> git clone https://github.com/asdf-vm/asdf.git ~/.asdf

$> cd ~/.asdf
$> git checkout "$(git describe --abbrev=0 --tags)"

$> echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
$> echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

Erlang

<sub><sup>_Assumes you want a full installation of support packages, please refer to [asdf-erlang](https://github.com/asdf-vm/asdf-erlang) for more details._</sup></sub>
```shell
$> apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop
$> asdf install erlang 22.2
```

Elixir
```shell
$> apt-get -y install unzip
$> asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
$> asdf install elixir 1.9.4
    ```

## Development Configuration
At its current state D-Boutique identifies the cluster by the computer name so you will want to change the `cluster_id` in `config/config.exs` to match your computer name.

```shell
config :boutique,
  cluster_id: "YOUR_COMPUTER_NAME",
  port: "THE_PORT_NUMBER_YOU_WANT_TO_USE"
```

## Running the Project
Getting the dependencies and running the tests.
```shell
# Get the dependencies.
$> mix deps.get

# Run tests
$> mix test
```

To run the distributed tests you need to make sure that you have separate nodes started, each node is responsible for a range of data stores based on their
bucket names, in the test environment the nodes are divided as:
> a..g node
>
> h..n node
>
> o..u node
>
> v..z node

```shell
# cd into boutique app
$> cd apps/boutique

# start the first node
$> iex --sname a-g -S mix

# start the second node
$> iex --sname h-n -S mix

# start the third node
$> iex --sname o-u -S mix

# start the fourth node from the umbrella root to start the TCP server
$> cd ../../
$> iex --sname v-z -S mix test --only distributed
```
If you want to run the project on different computers,
make sure the computers are on the same network and have the same `~/.erlang.cookie` value.

Check Erlang's [epmd](http://erlang.org/doc/man/epmd.html) for more information.

Running the project in a  cluster:
```shell
# cd into boutique app
$> cd apps/boutique

# start the first node
$> iex --sname a-g -S mix

# start the second node
$> iex --sname h-n -S mix

# start the third node
$> iex --sname o-u -S mix

# start the fourth node from the umbrella root to start the TCP server
$> cd ../../
$> iex --sname v-z -S mix
14:27:57.773 [info]  Accepting connections on port 4040
```

Running the project in a single node, from the umbrella root, run:
```shell
$> iex -S mix
14:27:57.773 [info]  Accepting connections on port 4040
```

Making requests
```shell
# Use telent or any similar application protocol to connect over the TCP server
# feel free to have multiple telnet sessions to play around with.
$> telnet 127.0.0.1 4040 # or the port you have in your config.
$> CREATE shopping
OK

$> PUT shopping milk 3
OK

$> GET shopping milk
3
OK

$> DELETE shopping milk
OK

$> ^]
telnet> quit
Connection closed.
```

## Documentation
To generate the documentation for the projects run:
```shell
$> mix docs
```
Documentation files are generated in `docs/`, open `docs/index.html` to read the API reference, or any module of interest.

## Projects
### Boutique
This project starts a supervision tree that handles creating and updating the state of data stores using Elixir [Agents](https://hexdocs.pm/elixir/Agent.html) and [GenServers](https://hexdocs.pm/elixir/GenServer.html).

### Boutique Server
A TCP Server, listens to a port until the port is available and get hold of the socket.
Once a client connection is established on the port it accepts it and proceeds to read the client requests and writes responses back.

## Notes
This project was created for educational purposes only, I created it to learn more about distributed systems, the Elixir process life cycle, concurrency, and state mutation.

Check out Elixir's [Introduction to Mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) for more information.

Due the beam VM and OTP implementation, all nodes on the network can access any process in any other node on the cluster by default which is a security concern,
in general communication between nodes should happen using SSL or any kind of encrypted messaging you'd like to use.
Erlang provides a powerful `:rpc` module that can be used for secure communication between nodes of a cluster. Currently this project does not use the `:rpc` module.

## Useful Resources:
- Learn You Some Erlang: Distribution chapter: [Distribunomicon](https://learnyousomeerlang.com/distribunomicon)
- CAP Theorem: [Brewer's CAP Theorem](http://www.julianbrowne.com/article/brewers-cap-theorem)
- You Can't Sacrifice [Partition Tolerance](https://codahale.com/you-cant-sacrifice-partition-tolerance/)
- Processes in Elixir: [Process](https://hexdocs.pm/elixir/Process.html)
- GenServers: [GenServer](https://hexdocs.pm/elixir/GenServer.html)
