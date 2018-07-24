FROM bitwalker/alpine-elixir:1.6.6

WORKDIR /usr/src/app

COPY mix.exs mix.lock /usr/src/app/
COPY config /usr/src/app/config

RUN apk add --update git

RUN mix do local.hex --force, local.rebar --force, deps.get, deps.compile

COPY . /usr/src/app
CMD ["elixir"]
