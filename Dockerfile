FROM rust:1.86-bookworm AS rust-builder
WORKDIR /app
COPY . .
RUN cargo build --release
RUN strip target/release/zenproxy

FROM golang:1.25-bookworm AS go-builder
WORKDIR /app
COPY sing-box-zenproxy ./sing-box-zenproxy
WORKDIR /app/sing-box-zenproxy
RUN CGO_ENABLED=0 go build -o /out/sing-box -tags with_clash_api ./cmd/sing-box

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=rust-builder /app/target/release/zenproxy .
COPY --from=go-builder /out/sing-box ./sing-box
COPY config.toml .
RUN mkdir -p data
EXPOSE 3000 9090
CMD ["./zenproxy"]
