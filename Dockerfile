ARG ALPINE_VERSION="3.10"
ARG S6_OVERLAY_VERSION="1.22.1.0"

FROM golang:1.11-alpine${ALPINE_VERSION} AS builder

ENV GPHOTOS_UPLOADER_VERSION v0.8.3
ENV OAUTH2CLI_VERSION v1.5.0

COPY patches /tmp/patches

RUN \
    apk update && \
    apk add --no-cache --virtual build-dependencies \
        g++ \
        git \
        make && \
    rm -rf /var/cache/apk/* && \
    git clone https://github.com/int128/oauth2cli.git && \
    cd oauth2cli && \
    git checkout ${OAUTH2CLI_VERSION} && \
    git apply /tmp/patches/oauth2cli/*_${OAUTH2CLI_VERSION}.patch && \
    cd .. && \
    git clone https://github.com/gphotosuploader/gphotos-uploader-cli.git && \
    cd gphotos-uploader-cli && \
    git checkout ${GPHOTOS_UPLOADER_VERSION} && \
    git apply /tmp/patches/gphotos-uploader-cli/*_${GPHOTOS_UPLOADER_VERSION}.patch && \
    make build VERSION="${GPHOTOS_UPLOADER_VERSION}-docker" && \
    cp gphotos-uploader-cli /go/bin/

FROM amd64/alpine:${ALPINE_VERSION}

LABEL maintainer="master@ricardoamaral.net"

ARG BUILD_DATE
ARG S6_OVERLAY_VERSION
ARG VCS_REF

LABEL \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Mass upload media folders to your Google Photos account with this Docker image." \
    org.label-schema.name="rfgamaral/gphotos-uploader" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/rfgamaral/docker-gphotos-uploader.git"

ENV GPU_SCHEDULE="0 */8 * * *"

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz /tmp/

RUN \
    apk update && \
    apk add --no-cache \
        bash \
        ca-certificates \
        curl && \
    rm -rf /var/cache/apk/* && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz --directory / && \
    rm -rf /tmp/*

COPY --from=builder /go/bin/gphotos-uploader-cli /usr/local/bin/gphotos-uploader-cli.bin

COPY rootfs/ /

VOLUME ["/config", "/photos"]

ENTRYPOINT ["/init"]
