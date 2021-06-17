#!/usr/bin/env bash
registry="registry.dclingcloud.com/library"
version="1.33.1"
tag="glibc"
set -Eeuo pipefail
base="${registry}/busybox:${version}-${tag}"
dir="."
set -x

# 合并Dockerfile.builder和Dockerfile.run到Dockerfile文件，实现多阶段编译
cat Dockerfile.builder > Dockerfile
echo -e '\n\n#--------------------------' >> Dockerfile
cat Dockerfile.run  >> Dockerfile

# 执行构建不同架构下的镜像，并将镜像保存在本地，需要分别指定平台架构，并保存为不同的镜像名称，指定输出类型为docker
# docker buildx build -t "$base-arm64" --build-arg BUSYBOX_VERSION="$version" --platform=linux/arm64 -o type=docker -f Dockerfile.builder "$dir"
# docker buildx build -t "$base-amd64" --build-arg BUSYBOX_VERSION="$version" --platform=linux/amd64 -o type=docker -f Dockerfile.builder "$dir"

# 直接构建多架构镜像，并推送到私有harbor镜像仓库（harbor2.0以上才支持多架构镜像）
docker buildx build -t "$base" --build-arg BUSYBOX_VERSION="$version" --platform=linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/386,linux/arm/v7,linux/arm/v6 "$dir" --push

docker pull "$base"
# 验证镜像不同架构版本
# imglist=$(docker buildx imagetools inspect "$base" | grep -E -o "${base}@sha256.*")

docker buildx imagetools inspect "$base"

# 打tag标记为glibc
docker tag "$base" "${registry}/busybox:${tag}"
# push到远程仓库
docker push "${registry}/busybox:${tag}"
