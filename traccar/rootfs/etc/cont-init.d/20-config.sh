#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: Traccar
# Ensures the user configuration file is present
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

if ! hass.file_exists "/config/traccar.xml"; then
    cp /etc/traccar/traccar.xml /config/traccar.xml
fi
