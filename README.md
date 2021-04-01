# busybox-glibc-docker
This is a docker file repo to build a minimal busybox image with required glibc libraries.

You can add your requires lib, and Docker.builder will search the list of requires lib in /lib/$(gcc -print-multiarch)/, if not exist in, you should modify Docker.builder to add it. 

RUN
```shell
sh build.sh
```
to build the image.
