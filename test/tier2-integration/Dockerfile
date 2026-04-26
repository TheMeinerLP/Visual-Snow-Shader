# =====================================================
#  Iris Shader Test Container
#  Headless Minecraft + Fabric + Iris + Sodium
#  + Mesa LLVMpipe (software OpenGL) + Xvfb
# =====================================================

FROM eclipse-temurin:21-jdk-jammy

ARG MC_VERSION=1.21.1
ARG IRIS_VERSION=1.7.5
ARG SODIUM_VERSION=mc1.21.1-0.5.11
ARG FABRIC_LOADER_VERSION=0.16.0
ARG FABRIC_API_VERSION=0.102.0+1.21.1
ARG FABRIC_INSTALLER_VERSION=1.0.1

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV MESA_GL_VERSION_OVERRIDE=4.5

# Mesa + Xvfb + tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb \
        libgl1-mesa-dri \
        libglu1-mesa \
        mesa-utils \
        libxi6 \
        libxxf86vm1 \
        libxrandr2 \
        libxcursor1 \
        libxinerama1 \
        ca-certificates \
        curl \
        unzip \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Working layout
WORKDIR /opt/mctest
RUN mkdir -p /opt/mctest/mc /opt/mctest/mods /opt/mctest/shaderpacks /opt/mctest/logs

# Fabric installer — installs headless via server-mode variant
# or client mode with offline tweaks. Here: minimal client.
RUN curl -fSL "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar" \
    -o /opt/mctest/fabric-installer.jar

# Iris + Sodium + Fabric API
RUN curl -fSL "https://github.com/IrisShaders/Iris/releases/download/v${IRIS_VERSION}%2Bmc${MC_VERSION}/iris-mc${MC_VERSION}-${IRIS_VERSION}.jar" \
    -o /opt/mctest/mods/iris.jar 2>/dev/null \
 || echo "WARN: Iris download failed for ${IRIS_VERSION}+mc${MC_VERSION} — please adjust the URL manually from Modrinth/GitHub"

RUN curl -fSL "https://api.modrinth.com/v2/project/sodium/version" \
    | jq -r --arg mc "${MC_VERSION}" '.[] | select(.game_versions[] == $mc) | .files[0].url' \
    | head -1 | xargs -I {} curl -fSL "{}" -o /opt/mctest/mods/sodium.jar 2>/dev/null \
 || echo "WARN: Sodium download via API failed"

RUN curl -fSL "https://api.modrinth.com/v2/project/fabric-api/version" \
    | jq -r --arg mc "${MC_VERSION}" '.[] | select(.game_versions[] == $mc) | .files[0].url' \
    | head -1 | xargs -I {} curl -fSL "{}" -o /opt/mctest/mods/fabric-api.jar 2>/dev/null \
 || echo "WARN: Fabric API download via API failed"

COPY entrypoint.sh /opt/mctest/entrypoint.sh
RUN chmod +x /opt/mctest/entrypoint.sh

ENTRYPOINT ["/opt/mctest/entrypoint.sh"]
