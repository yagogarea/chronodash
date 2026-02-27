ARG MIX_ENV="prod"

################################################################################
# BUILDER STAGE
################################################################################
FROM elixir:1.19.5-otp-28-alpine AS builder

ARG MIX_ENV

RUN apk add --no-cache --update \
    build-base \
    git \
    openssh-client \
    && rm -rf /var/cache/apk/*

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR "/app"

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN --mount=type=ssh mix deps.get --only ${MIX_ENV}
RUN mix deps.compile --only ${MIX_ENV}

COPY config config
COPY lib lib
COPY priv priv

RUN mix release

################################################################################
# RUNNER STAGE
################################################################################
FROM alpine:3.23 AS runner

ARG MIX_ENV

RUN apk add --no-cache --update \
    libstdc++ \
    openssl \
    ncurses-libs \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR "/app"
RUN chown nobody /app

COPY --from=builder --chown=nobody:nobody /app/_build/${MIX_ENV}/rel/chronodash ./

USER nobody

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ./bin/chronodash rpc "Elixir.Chronodash.Repo.query!(\"SELECT 1\")" || exit 1

CMD ["./bin/chronodash", "start"]
