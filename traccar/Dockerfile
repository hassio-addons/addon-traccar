ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:7.3.3
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Configure locale
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
ARG BUILD_ARCH="amd64"
ARG TRACCAR_VERSION="v5.12"

# Set working dir
WORKDIR /opt/traccar

ENV JAVA_HOME /opt/java/openjdk
ENV PATH $JAVA_HOME/bin:$PATH

RUN set -ex \
    \
    && apt-get update \
    \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget \
        nginx=1.22.1-9 \
        mariadb-client=1:10.11.6-0+deb12u1 \
        xmlstarlet=1.6.1-3 \
        unzip=6.0-28 \
        # java.lang.UnsatisfiedLinkError: libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
        # java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
        # https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
        fontconfig=2.14.1-4 \
        # utilities for keeping Ubuntu and OpenJDK CA certificates in sync
        # https://github.com/adoptium/containers/issues/293
        ca-certificates \
        p11-kit=0.24.1-2 \
        # locales ensures proper character encoding and locale-specific behaviors using en_US.UTF-8
        locales=2.36-9+deb12u4 \
    \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    \
    # Install OpenJDK 11 JRE from Adoptium
    && \
    case "${BUILD_ARCH}" in \
    aarch64) \
        ESUM='46e2bff7d5f419ac7c2fad29e78bfacf49ead4a2de1aba73b6329128f6d1f707'; \
        BINARY_URL='https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22%2B7/OpenJDK11U-jre_aarch64_linux_hotspot_11.0.22_7.tar.gz'; \
        ;; \
    amd64|i386) \
        ESUM='3a0fec1b9ef38d6abd86cf11f6001772b086096b6ec2588d2a02f1fa86b2b1de'; \
        BINARY_URL='https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22%2B7/OpenJDK11U-jre_x64_linux_hotspot_11.0.22_7.tar.gz'; \
        ;; \
    armhf|armv7) \
        ESUM='a5ab40aa53ecd413a8af738e66855d423e64b5389f876a4825e2cbdb45e9cfb3'; \
        BINARY_URL='https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22%2B7/OpenJDK11U-jre_arm_linux_hotspot_11.0.22_7.tar.gz'; \
        ;; \
    *) \
        echo "Unsupported arch: ${BUILD_ARCH}"; \
        exit 1; \
        ;; \
    esac \
    && wget --progress=dot:giga -O /tmp/openjdk.tar.gz ${BINARY_URL} \
    && echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c - \
    && mkdir -p "$JAVA_HOME" \
    && tar --extract \
    --file /tmp/openjdk.tar.gz \
    --directory "$JAVA_HOME" \
    --strip-components 1 \
    --no-same-owner \
    \
    # https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
    && find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf \
    && ldconfig \
    # https://github.com/docker-library/openjdk/issues/212#issuecomment-420979840
    # https://openjdk.java.net/jeps/341
    && java -Xshare:dump \
    \
    # Install Traccar
    && wget -qO /tmp/traccar.zip "https://github.com/traccar/traccar/releases/download/${TRACCAR_VERSION}/traccar-other-${TRACCAR_VERSION#v}.zip" \
    && unzip -qo /tmp/traccar.zip -d /opt/traccar \
    \
    # Cleanup
    && rm -f ${JAVA_HOME}/lib/src.zip \
    && apt-get autoremove --yes unzip wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
