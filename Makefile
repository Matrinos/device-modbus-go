.PHONY: build test clean prepare update docker

GO=CGO_ENABLED=0 GO111MODULE=on go
GOCGO=CGO_ENABLED=1 GO111MODULE=on go
GOBUILD=GOOS=linux GOARCH=arm64

MICROSERVICES=cmd/device-modbus

.PHONY: $(MICROSERVICES)

DOCKERS=docker_device_modbus_go
.PHONY: $(DOCKERS)

VERSION=$(shell cat ./VERSION 2>/dev/null || echo 0.0.0)

GIT_SHA=$(shell git rev-parse HEAD)
GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-modbus-go.Version=$(VERSION)"

build: $(MICROSERVICES)

cmd/device-modbus:
	go mod tidy
	$(GOBUILD) $(GOCGO) build $(GOFLAGS) -o $@ ./cmd

test:
	go mod tidy
	$(GOCGO) test ./... -coverprofile=coverage.out
	$(GOCGO) vet ./...
	gofmt -l .
	[ "`gofmt -l .`" = "" ]
	./bin/test-attribution-txt.sh
	./bin/test-go-mod-tidy.sh

clean:
	rm -f $(MICROSERVICES)

docker: $(DOCKERS)

docker_device_modbus_go:
	docker build \
		--label "git_sha=$(GIT_SHA)" \
		-t edgexfoundry/device-modbus:$(GIT_SHA) \
		-t edgexfoundry/device-modbus:$(VERSION)-dev \
		.
