FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -ldflags="-s -w" -o xpay-server ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S xpay \
    && adduser -S -G xpay xpay
WORKDIR /app
COPY --from=builder /app/xpay-server .
RUN chown -R xpay:xpay /app
USER xpay
EXPOSE 3402
CMD ["./xpay-server"]
