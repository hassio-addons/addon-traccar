#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Traccar
# Ensures the user configuration file is present
# ==============================================================================
if ! bashio::fs.file_exists "/config/traccar.xml"; then
    cp /etc/traccar/traccar.xml /config/traccar.xml
fi
