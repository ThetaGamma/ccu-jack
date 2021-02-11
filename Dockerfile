# V0.4
# # with build, download latest release from github
# use "stable" release from mdzio
#
# 1. build the image with
#   docker build -t ccu-jack:latest .
# 2. mount your config into container and run the image, i.e.
# 
#   docker run --rm  -v "$PWD"/wd/ccu-jack.cfg:/go/src/app/ccu-jack.cfg:ro ccu-jack:latest
FROM golang:1.15-alpine as builder

ARG BUILD_DATE
ARG BUILD_VERSION=1.0.1

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$BUILD_VERSION \
      org.opencontainers.image.title="CCU-Jack" \
      org.opencontainers.image.description="REST/MQTT-Server for the HomeMatic CCU" \
      org.opencontainers.image.vendor="CCU-Jack OpenSource Project" \
      org.opencontainers.image.authors="mdzio <info@ccu-historian.de>" \
      org.opencontainers.image.licenses="GPL-3.0 License" \
      org.opencontainers.image.url="https://github.com/mdzio/ccu-jack" \
      org.opencontainers.image.documentation="https://github.com/mdzio/ccu-jack/blob/master/README.md"

# Set work directory
WORKDIR /go/src/app
# Get the latest relase from github and extract it locally
RUN apk add --no-cache curl && \
    curl -SL "https://github.com/mdzio/ccu-jack/releases/download/v${BUILD_VERSION}/ccu-jack-linux-${BUILD_VERSION}.tar.gz" | tar -xvzC . && \
    mkdir -p /go/src/app /data  && \
    adduser -h /go/src/app -D -H ccu-jack -u 1000 && \
    chown -R ccu-jack:root /data && chmod -R g+rwX /data && \
    chown -R ccu-jack:root /go/src/app && chmod -R g+rwX /go/src/app

FROM scratch as RUN
WORKDIR /go/src/app
COPY --from=builder /etc/passwd /etc/passwd
#USER ccu-jack

# MQTT, MQTT TLS, CCU-Jack VEAM/UI, CCU-Jack VEAM/UI TLS
EXPOSE 1883 8883 2121 2122

# Add a healthcheck (default every 30 secs)
HEALTHCHECK CMD curl -s -o /dev/null -il -w "%{http_code}\n" http://localhost:2121 | grep -Eq "(200|401)" || exit 1

COPY --from=builder /go/src/app/ccu-jack .
# start it up
CMD ["./ccu-jack"]