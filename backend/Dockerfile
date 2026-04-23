FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o indexer ./cmd/indexer

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/indexer .
CMD ["./indexer"]
