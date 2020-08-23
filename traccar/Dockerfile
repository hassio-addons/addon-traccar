ARG BUILD_FROM=hassioaddons/base:8.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy root filesystem
COPY rootfs /

# Set working dir
WORKDIR /opt/traccar

# Setup base
RUN \
    apk add --no-cache \
        mariadb-client=10.4.13-r0 \
        nginx=1.18.0-r0 \
        nss=3.55-r0 \
        openjdk8-jre=8.252.09-r0 \
        xmlstarlet=1.6.1-r0 \
    \
    && curl -J -L -o /tmp/traccar.zip \
      "https://github.com/traccar/traccar/releases/download/v4.10/traccar-other-4.10.zip" \
    \
    && mkdir -p /opt/traccar \
    && unzip -d /opt/traccar /tmp/traccar.zip \
    \
    && rm -fr /tmp/*

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Traccar" \
    io.hass.description="Modern GPS Tracking Platform" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="Traccar" \
    org.opencontainers.image.description="Modern GPS Tracking Platform" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/hassio-addons/addon-traccar" \
    org.opencontainers.image.documentation="https://github.com/hassio-addons/addon-traccar/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
