# Dockerfile to build image of Golang app - size 14MB
FROM golang:alpine AS builder

WORKDIR /app

ADD go.mod .

COPY . .

RUN go build -o app

FROM alpine

WORKDIR /app

COPY --from=builder /app /app

ARG BIND_ADDRESS 8080
ENV BIND_ADDRESS $BIND_ADDRESS
ENV PORT 8080

#EXPOSE 8080

CMD ["./app"]
