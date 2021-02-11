# V0.3
# # with build, download latest release from github
# 
# 1. build the image with
#   docker build -t ccu-jack:latest .
# 2. mount your config into container and run the image, i.e.
# 
#   docker run --rm  -v "$PWD"/wd/ccu-jack.cfg:/go/src/app/ccu-jack.cfg:ro ccu-jack:latest
FROM golang:1.15-alpine as builder
WORKDIR /go/src/app
# Get the latest relase from github and extract it locally
RUN apk add --no-cache curl && \
    curl -SL https://github.com/mdzio/ccu-jack/releases/download/v1.0.1/ccu-jack-linux-1.0.1.tar.gz | tar -xvzC .

FROM scratch as RUN
WORKDIR /go/src/app
COPY --from=builder /go/src/app/ccu-jack .
# start it up
CMD ["./ccu-jack"]