FROM golang:1.11-alpine3.8

LABEL maintainer="master@ricardoamaral.net"

ARG S6_OVERLAY_VERSION="1.21.7.0"

ENV GPU_SCHEDULE="0 */8 * * *"

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp/

RUN \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    apk update && \
    apk add --no-cache --virtual build-dependencies \
        git && \
    apk add --no-cache \
        curl && \
    go get -u github.com/nmrshll/gphotos-uploader-cli/cmd/gphotos-uploader-cli && \
    cd /go/src/github.com/nmrshll && \
    rm -rf oauth2-noserver && \
    git clone https://github.com/rfgamaral/oauth2-noserver.git --branch docker && \
    cd gphotos-uploader-cli/cmd/gphotos-uploader-cli && \
    go install && \
    apk del build-dependencies && \
    rm -rf /tmp/*

COPY rootfs/ /

VOLUME ["/config", "/photos"]

ENTRYPOINT ["/init"]
