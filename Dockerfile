FROM elixir:1.5.2
ENV DEBIAN_FRONTEND="noninteractive"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY mix.exs mix.lock /usr/src/app/
COPY config /usr/src/app/config
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix deps.compile

COPY . /usr/src/app
CMD ["elixir"]
