############################
# STEP 1 build executable binary
############################
# FROM public.ecr.aws/vend/golang:1.8-alpine AS builder
FROM 525158249545.dkr.ecr.us-west-2.amazonaws.com/golang:1.16.5-alpine3.13 AS builder
# FROM golang:alpine AS builder
# Install git.
# Git is required for fetching the dependencies.
RUN apk --update add ca-certificates
RUN apk update && apk add --no-cache git
# Create appuser.
# ENV USER=appuser
# ENV UID=10001 
# # See https://stackoverflow.com/a/55757473/12429735RUN 
# RUN adduser \    
#     -g "" \    
#     -h "/nonexistent" \    
#     -s "/sbin/nologin" \    
#     -H \    
#     -u "${UID}" \    
#     "${USER}"
WORKDIR $GOPATH/src/github.com/prabhatsharma/sample-microservice/
COPY . .
# Fetch dependencies.
# Using go get.
RUN go get -d -v
# Using go mod.
# RUN go mod download
# RUN go mod verify
# Build the binary.
# to tackle error standard_init_linux.go:207: exec user process caused "no such file or directory" set CGO_ENABLED=0   
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main
############################
# STEP 2 build a small image
############################
FROM scratch
# Import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy the ssl certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Copy our static executable.
COPY --from=builder  /go/src/github.com/prabhatsharma/sample-microservice/main /go/bin/main

# Use an unprivileged user.
# USER appuser:appuser
# Port on which the service will be exposed.
EXPOSE 6080
# Run the binary.
ENTRYPOINT ["/go/bin/main"]
