FROM debian:buster-slim AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update && \
    apt-get install -y git clang cmake curl && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y && \
    git clone --depth 1 --branch v$VERSION --single-branch https://github.com/romanz/electrs.git .

RUN ~/.cargo/bin/cargo build --release --bin electrs

FROM debian:buster-slim

RUN adduser --disabled-password --uid 1000 --home /data --gecos "" electrs

USER electrs

WORKDIR /data

COPY --from=builder /build/target/release/electrs /bin/electrs

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT ["electrs"]
