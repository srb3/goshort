# Makefile for Go Projects

# Variables
BINARY_NAME=goshort
BINARY_DIR="./bin/"
BINARY_PATH="$(BINARY_DIR)/$(BINARY_NAME)"
VERSION=$(shell git describe --tags --always --dirty || echo "v0.1.0")
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS="-s -w -X main.version=$(VERSION) -X main.buildDate=$(BUILD_DATE)"
DOCKER_ORG=srbrown
DOCKER_IMAGE=$(DOCKER_ORG)/$(BINARY_NAME)
TAG=$(VERSION)
LATEST_TAG=latest

# .PHONY declares that these targets are not actual files
.PHONY: all build test install deps fmt vet clean run lint docs         docker-build docker-run docker-push docker-push-latest docker-push-all docker-build-push         build-arm64 build-windows-amd64 cross-compile help tidy

# Default target
all: build

# Build the Go application
build:
	@echo "Building $(BINARY_NAME)..."
	go build -ldflags $(LDFLAGS) -o $(BINARY_PATH) ./cmd/main.go

# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Install the Go application
install:
	@echo "Installing $(BINARY_NAME) to $(GOBIN)..."
	go install ./cmd/main.go

# Manage dependencies
deps:
	@echo "Updating dependencies..."
	GOFLAGS= go get -u ./...
	GOFLAGS= go mod tidy

# Format the code
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Vet the code
vet:
	@echo "Running go vet..."
	go vet ./...

# Tidy dependencies
tidy:
	@echo "Tidying dependencies..."
	go mod tidy

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(BINARY_PATH)

# Run the application
run: build
	@echo "Running $(BINARY_NAME)..."
	./$(BINARY_PATH)

# Lint the code (requires golangci-lint installed)
lint:
	@echo "Running linters..."
	golangci-lint run

# Generate documentation
docs:
	@echo "Generating documentation..."
	godoc -http=:6060 &

# Docker Build
docker-build: build
	@echo "Building Docker image $(DOCKER_IMAGE):$(TAG)..."
	docker build --build-arg VERSION=$(VERSION) --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg BINARY_NAME=$(BINARY_NAME) -t $(DOCKER_IMAGE):$(TAG) .

# Docker Run
docker-run:
	@echo "Running Docker container from image $(DOCKER_IMAGE):$(TAG)..."
	docker run --rm -p 8080:8080 $(DOCKER_IMAGE):$(TAG)

# Docker Push with specific tag
docker-push:
	@echo "Pushing Docker image $(DOCKER_IMAGE):$(TAG) to Docker Hub..."
	docker push $(DOCKER_IMAGE):$(TAG)

# Docker Push with latest tag
docker-push-latest:
	@echo "Tagging Docker image $(DOCKER_IMAGE):$(TAG) as $(DOCKER_IMAGE):$(LATEST_TAG)..."
	docker tag $(DOCKER_IMAGE):$(TAG) $(DOCKER_IMAGE):$(LATEST_TAG)
	@echo "Pushing Docker image $(DOCKER_IMAGE):$(LATEST_TAG) to Docker Hub..."

# Docker Push All (both specific tag and latest)
docker-push-all: docker-push docker-push-latest

# Docker Build and Push
docker-build-push: docker-build docker-push docker-push-latest
	@echo "Docker image built and pushed with tags $(TAG) and $(LATEST_TAG)."

# Cross-compile for ARM64
build-arm64:
	@echo "Building $(BINARY_NAME) for ARM64..."
	GOOS=linux GOARCH=arm64 go build -ldflags $(LDFLAGS) -o $(BINARY_PATH)_arm64 ./cmd/main.go

# Cross-compile for Windows AMD64
build-windows-amd64:
	@echo "Building $(BINARY_NAME) for Windows AMD64..."
	GOOS=windows GOARCH=amd64 go build -ldflags $(LDFLAGS) -o $(BINARY_NAME)_windows_amd64.exe ./cmd/main.go

# Cross-compile all
cross-compile: build-arm64 build-windows-amd64
	@echo "Cross-compilation complete for ARM64 and Windows AMD64."

# Help target to display available commands
help:
	@echo "Available Make targets:"
	@echo "  all                 - Build the application (default)"
	@echo "  build               - Compile the Go application"
	@echo "  test                - Run tests"
	@echo "  install             - Install the Go application to GOBIN"
	@echo "  deps                - Update and tidy dependencies"
	@echo "  fmt                 - Format the code"
	@echo "  vet                 - Vet the code for potential issues"
	@echo "  lint                - Run linters (golangci-lint)"
	@echo "  clean               - Remove build artifacts"
	@echo "  run                 - Build and run the application"
	@echo "  docs                - Generate documentation"
	@echo "  docker-build        - Build Docker image with specific tag"
	@echo "  docker-run          - Run Docker container from specific tag"
	@echo "  docker-push         - Push Docker image with specific tag to Docker Hub"
	@echo "  docker-push-latest  - Push Docker image with 'latest' tag to Docker Hub"
	@echo "  docker-push-all     - Push Docker image with both specific and 'latest' tags to Docker Hub"
	@echo "  docker-build-push   - Build and push Docker image with specific and 'latest' tags"
	@echo "  build-arm64         - Build the application for ARM64 architecture"
	@echo "  build-windows-amd64 - Build the application for Windows AMD64 architecture"
	@echo "  cross-compile       - Build the application for ARM64 and Windows AMD64 architectures"
	@echo "  tidy                - Tidy Go module dependencies"
	@echo "  help                - Show this help message"
