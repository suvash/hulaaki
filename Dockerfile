FROM elixir:1.5.1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY ./mix.* /usr/src/app/
RUN yes | mix do deps.get && yes | MIX_ENV=test mix do deps.get, deps.compile

COPY . /usr/src/app
CMD ["elixir"]