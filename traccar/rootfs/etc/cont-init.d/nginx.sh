#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community App: Traccar
# Configures NGINX for use with the Traccar server
# ==============================================================================

# Generate direct access configuration, if enabled.
if bashio::var.has_value "$(bashio::app.port 80)"; then
    bashio::config.require.ssl
    bashio::var.json \
        certfile "$(bashio::config 'certfile')" \
        keyfile "$(bashio::config 'keyfile')" \
        port "^$(bashio::app.port 80)" \
        ssl "^$(bashio::config 'ssl')" \
        | tempio \
            -template /etc/nginx/templates/direct.gtpl \
            -out /etc/nginx/servers/direct.conf
fi
