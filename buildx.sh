#!/usr/bin/env bash
registry="registry.dclingcloud.com/library"
tag="glibc"
set -Eeuo pipefail
base="${registry}/busybox:${tag}"
dir="."
set -x

# 执行构建不同架构下的镜像，并将镜像保存在本地，需要分别指定平台架构，并保存为不同的镜像名称，指定输出类型为docker
# docker buildx build -t "$base-arm64" --platform=linux/arm64 -o type=docker -f Dockerfile.builder "$dir"
# docker buildx build -t "$base-amd64" --platform=linux/amd64 -o type=docker -f Dockerfile.builder "$dir"

# 直接构建多架构镜像，并推送到私有harbor镜像仓库（harbor2.0以上才支持多架构镜像）
docker buildx build -t "$base" --platform=linux/amd64,linux/arm64 -f Dockerfile.builder "$dir" --push

# 验证镜像不同架构版本
# imglist=$(docker buildx imagetools inspect "$base" | grep -E -o "${base}@sha256.*")

docker buildx imagetools inspect "$base"