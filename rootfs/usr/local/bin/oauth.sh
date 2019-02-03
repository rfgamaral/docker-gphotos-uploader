#!/bin/sh

case "${1}" in
    "start")
        gphotos-uploader-cli
        ;;
    "store-token")
        curl -sSL ${2} > /dev/null
        ;;
esac
