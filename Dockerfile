ARG ALPINE_VERSION="3.8"
ARG S6_OVERLAY_VERSION="1.21.7.0"

FROM golang:1.11-alpine${ALPINE_VERSION} AS builder

RUN \
    apk update && \
    apk add --no-cache --virtual build-dependencies \
        git && \
    go get -u github.com/nmrshll/gphotos-uploader-cli/cmd/gphotos-uploader-cli && \
    cd /go/src/github.com/nmrshll && \
    rm -rf oauth2-noserver && \
    git clone https://github.com/rfgamaral/oauth2-noserver.git --branch docker && \
    cd gphotos-uploader-cli/cmd/gphotos-uploader-cli && \
    GOOS=linux GOARCH=amd64 go build -ldflags='-w -s' -o /go/bin/gphotos-uploader-cli && \
    apk del build-dependencies
FROM alpine:${ALPINE_VERSION}

LABEL maintainer="master@ricardoamaral.net"

ARG S6_OVERLAY_VERSION

ENV GPU_SCHEDULE="0 */8 * * *"

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp/

RUN \
    apk update && \
    apk add --no-cache \
        curl && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm -rf /tmp/*

COPY --from=builder /go/bin/gphotos-uploader-cli /usr/local/bin/gphotos-uploader-cli

COPY rootfs/ /

VOLUME ["/config", "/photos"]

ENTRYPOINT ["/init"]
