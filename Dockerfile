FROM golang:1.11.1-alpine3.8 AS builder

# Receive argument from command when building a service
ARG service

# Install git, curl and openssh
RUN apk add --no-cache git curl openssh

# Copy the code from the host and compile it
WORKDIR /src/go
COPY go.mod go.sum ./

RUN go mod download

COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /app "./${service}"

FROM alpine:3.8
RUN apk update && \
   apk add curl ca-certificates && \
   rm -rf /var/cache/apk/** && \
   update-ca-certificates

COPY --from=builder /app ./
ENTRYPOINT ["./app"]
