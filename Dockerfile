FROM elixir:1.6.5-alpine

WORKDIR /usr/src/app

COPY mix.exs mix.lock /usr/src/app/
COPY config /usr/src/app/config

RUN mix do local.hex --force, local.rebar --force, deps.get, deps.compile

COPY . /usr/src/app
CMD ["elixir"]
