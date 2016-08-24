# Hulaaki (हुलाकी)

[![Build Status](https://travis-ci.org/suvash/hulaaki.svg?branch=master)](https://travis-ci.org/suvash/hulaaki?branch=master)
[![Coverage Status](https://coveralls.io/repos/suvash/hulaaki/badge.svg?branch=master)](https://coveralls.io/r/suvash/hulaaki?branch=master)
[![Inline docs](http://inch-ci.org/github/suvash/hulaaki.svg?branch=master)](http://inch-ci.org/github/suvash/hulaaki?branch=master)

Hulaaki is a client library for MQTT 3.1.1 entirely written in Elixir.

## Usage

Before we get started, keep in mind that you need a running MQTT
server that you can connect to.

Add Hulaaki to your project dependencies in `mix.exs`

```elixir
def deps do
  [{:hulaaki, "~> 0.0.4"} ]
end
```

The quickest way to get up and running with Hulaaki is to `use` the
provided `Client` module. This Genserver module defines function
callbacks that are intended to be overridden for required
implementations. The callbacks are defined for each MQTT message that
is being sent and received from the server.

Add the following sample client to your project.

```elixir
defmodule SampleClient do
  use Hulaaki.Client

  def on_connect_ack(options) do
    IO.inspect options
  end

  def on_subscribed_publish(options) do
    IO.inspect options
  end

  def on_subscribe_ack(options) do
    IO.inspect options
  end

  def on_pong(options) do
    IO.inspect options
  end
end
```

Load the project in `iex -S mix` to explore the SampleClient

```
$ iex -S mix

> {:ok, pid} = SampleClient.start_link(%{})

> options = [client_id: "some-name", host: "localhost", port: 1883]

> SampleClient.connect(pid, options)

> SampleClient.ping(pid)

```

Once you get the idea, feel free to check the inline documentation and
[client_test.exs](test/hulaaki/client_test.exs) for more example usage
and test strategy.

## Documentation

Please refer to the inline documentation and tests to explore the
documentation for now. This shall be improved over time.

## Immediate TODOs
* Pingpong based heartbeat in Client based on the timeout.
* .....

## Contributing

Pull requests with appropriate tests and improvements are welcome.
Mosquitto is currently used by the author to test the library.

### Running the tests

If you already have Elixir runtime and a MQTT broker running (on
standard ports), you should just be able to run `mix test` as you
would do on other mix projects.

As prefered by the author, you can also use the provided Makefile to
run the tests. The only dependency required is Docker on your machine.
```
# Make sure you have Docker running on your machine

# Start the MQTT Server
$ make mqtt-server-start

# Run the tests
$ make test

# Stop the MQTT server after all is over
$ make mqtt-server-stop

# Cleanup Docker images when all is done
# make clean

# To cleanup everything, it helps if you understand how to use Docker a bit.
# If not familiar and you want to stop and remove everything Docker related:
$ docker stop $(docker ps -aq)
$ docker rm $(docker ps -aq)
$ docker rmi $(docker images -aq)
```

## Changelog

Please check the [CHANGELOG.md](https://github.com/suvash/hulaaki/blob/master/CHANGELOG.md).

## Naming

Hulaaki(pronouced as who-laa-key) is the phonetic spelling of the word
हुलाकी in Nepali, which translates to Postman in English.
