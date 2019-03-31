ARG BUILD_FROM=hassioaddons/base:3.0.1
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
        nginx=1.14.2-r0 \
        openjdk8-jre=8.201.08-r0 \
    \
    && curl -J -L -o /tmp/traccar.zip \
      "https://github.com/traccar/traccar/releases/download/v4.3/traccar-other-4.3.zip" \
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
    io.hass.description="Modern GPS Tracking Platform." \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.label-schema.description="Modern GPS Tracking Platform." \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Traccar" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://community.home-assistant.io/t/community-hass-io-add-on-traccar/81407?u=frenck" \
    org.label-schema.usage="https://github.com/hassio-addons/addon-traccar/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/hassio-addons/addon-traccar" \
    org.label-schema.vendor="Community Hass.io Add-ons"
