FROM elixir:1.9.0 AS development

EXPOSE 4000
ENV PORT=4000 MIX_ENV=dev

LABEL maintainer="Chris Jewell <chrisjohnjewell@gmail.com>"

RUN mix local.hex --force && \
    mix local.rebar --force

# Install Postgres, Node and inotify-tools (for Live Reload)
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y \
       postgresql-client \
       nodejs \
       inotify-tools

WORKDIR /app

# Cache deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD apps/coin_flip_betting_game_engine/mix.exs ./apps/coin_flip_betting_game_engine/
ADD apps/coin_flip_betting_game_interface/mix.exs ./apps/coin_flip_betting_game_interface/
RUN mix do deps.get, deps.compile

ADD . .

RUN mix do deps.get, deps.compile
RUN cd apps/coin_flip_betting_game_interface && mix phx.digest; cd -

RUN mix compile

CMD ["mix", "phx.server"]
