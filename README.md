# Hulaaki (हुलाकी)

[![Build Status](https://travis-ci.org/suvash/hulaaki.svg?branch=master)](https://travis-ci.org/suvash/hulaaki?branch=master)
[![Coverage Status](https://coveralls.io/repos/suvash/hulaaki/badge.svg?branch=master)](https://coveralls.io/r/suvash/hulaaki?branch=master)
[![Hex.pm Project](https://img.shields.io/hexpm/v/hulaaki.svg)](https://hex.pm/packages/hulaaki)
[![Inline docs](http://inch-ci.org/github/suvash/hulaaki.svg?branch=master)](http://inch-ci.org/github/suvash/hulaaki?branch=master)

An Elixir library (driver) for clients communicating with MQTT
brokers(via the MQTT 3.1.1 protocol).

A quick tour of the features implemented right now:
- Qos 0 and Qos 1 support available. QoS 2 not supported yet.
- SSL/TLS support available.
- Automatic Ping based on keep alive timeout.
- Internal packet id generation for control packets with variable header.

## Naming

Hulaaki(pronouced as who-laa-key) is the phonetic spelling of the word
हुलाकी in Nepali, which translates to postman.

## Usage

Before we get started, keep in mind that you need a running MQTT
server that you can connect to.

Add Hulaaki to your project dependencies in `mix.exs`

```elixir
def deps do
  [{:hulaaki, "~> 0.1.0"} ]
end
```

The quickest way to get up and running with Hulaaki is to `use` the
provided `Client` module. This Genserver module defines function
callbacks that are intended to be overridden for required
implementations. The callbacks are defined for each MQTT message that
is being sent and received from the server.

Here's a [list of all the override-able callbacks to](lib/hulaaki/client.ex#L292-L318)use in your projects.

An example is present below that overrides some callbacks.

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

  def on_ping_response(options) do
    IO.inspect options
  end
end
```

Load the project in `iex -S mix` to explore the SampleClient

```
$ iex -S mix

> {:ok, pid} = SampleClient.start_link(%{})

> options = [client_id: "some-name-7490", host: "localhost", port: 8883, ssl: true]

> SampleClient.connect(pid, options)

> SampleClient.ping(pid)

```

Please check the inline documentation
and [client_tcp_test.exs](test/hulaaki/client_tcp_test.exs) for more example
usage and test strategy.

## Changelog

Please check the [CHANGELOG.md](https://github.com/suvash/hulaaki/blob/master/CHANGELOG.md).

## Documentation

Please refer to the inline documentation and client tests to explore
the documentation for now.

## Contributing

Pull requests with appropriate tests and improvements are welcome.
Mosquitto is currently used by the author to test the library.

### Running the tests

If you already have Elixir runtime and a MQTT broker running (on
standard ports), you should just be able to run `mix test` as you
would do on other mix projects.

As prefered by the author, you can also use the provided Makefile to
run the tests. In that case, you'll need the following on your machine
- GNU Make ( Version 4.0 and up )
- [Docker Engine](https://docs.docker.com/engine/installation/) ( Version 17.06.1 and hopefully upwards )
- [Docker Compose](https://github.com/docker/compose/releases) ( Version 1.16.1 and hopefully upwards )

```
# Get help
$ make help

# Start the MQTT servers (better to start separately to warm them up)
$ make start

# Run tests
$ make test

# Stop and cleanup docker instances etc.
# make stop
```
