# Step 1: Build stage
# Use the official Golang image to create a build artifact.
# This image is based on Debian, so it has a lot of the necessary tools and libraries.
FROM golang:1.22-alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN go build -o app .

# Step 2: Use a Docker multi-stage build to create a lean production image.
FROM alpine:latest

# Add ca-certificates in case you need to call HTTPS endpoints.
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/app .

# Expose port 1323 to the outside world
EXPOSE 1323

# Command to run the executable
CMD ["./app"]
