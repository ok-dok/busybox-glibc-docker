#!/usr/bin/env bash
tag="glibc"
set -Eeuo pipefail
base="busybox:$tag"
dir="."
set -x
docker build -t "$base-builder" -f Dockerfile.builder "$dir"
docker run --rm "$base-builder" tar cC rootfs . | xz -T0 -z9 > "$dir/busybox.tar.xz"
docker build -t "$base-test" "$dir"
docker run --rm "$base-test" sh -xec 'true'

# detect whether the current host _can_ ping
# (QEMU user-mode networking does not route ping traffic)
shouldPing=
if docker run --rm "$base-builder" ping -c 1 google.com &> /dev/null; then
    shouldPing=1
fi

if [ -n "$shouldPing" ]; then
    if ! docker run --rm "$base-test" ping -c 1 google.com; then
        sleep 1
        docker run --rm "$base-test" ping -c 1 google.com
    fi
else
    docker run --rm "$base-test" nslookup google.com
fi

docker images "$base-test"

docker build -t "$base" -f Dockerfile "$dir"

docker images "$base"
