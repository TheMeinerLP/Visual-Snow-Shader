FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        glslang-tools \
        python3 \
        findutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/shader-test
COPY entrypoint.sh /opt/shader-test/entrypoint.sh
COPY iris-shim.glsl /opt/shader-test/iris-shim.glsl
RUN chmod +x /opt/shader-test/entrypoint.sh

ENTRYPOINT ["/opt/shader-test/entrypoint.sh"]
