# Dockerfile

ARG VERSION
ARG BUILD_DATE
ARG BINARY_NAME

# Use the official Golang image for building the application
FROM golang:1.22-alpine AS builder

# Set environment variables
ENV GO111MODULE=on     CGO_ENABLED=0     GOOS=linux     GOARCH=amd64

# Create app directory
WORKDIR /app

# Copy go.mod and conditionally copy go.sum if it exists
COPY go.mod ./
RUN if [ -f go.sum ]; then cp go.sum .; fi
# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the Go app with embedded version and build date
RUN go build -ldflags "-s -w -X main.version=${VERSION} -X main.buildDate=${BUILD_DATE}" -o run ./cmd/main.go

# Use a minimal image for the final build
FROM alpine:latest

# Set environment variables
ENV PORT=8080

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy the binary from the builder
COPY --from=builder "/app/run" .

# Grant permissions
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE ${PORT}

# Command to run
CMD ["./run"]
