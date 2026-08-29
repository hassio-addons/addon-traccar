#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community App: Traccar
# Ensures a valid user configuration file is in place
#
# This runs before every other script, so the rest of the app can rely on the
# user configuration being present and parsable.
# ==============================================================================
readonly USER_CONFIG="/config/traccar.xml"

# Migrate app data from the Home Assistant config folder,
# to the app configuration folder.
if ! bashio::fs.file_exists "${USER_CONFIG}" \
    && bashio::fs.file_exists '/homeassistant/traccar.xml'; then
    mv /homeassistant/traccar.xml "${USER_CONFIG}" \
        || bashio::exit.nok "Failed to migrate Traccar configuration"
fi

if ! bashio::fs.file_exists "${USER_CONFIG}"; then
    cp /etc/traccar/traccar.xml "${USER_CONFIG}"
fi

# The properties DTD is referenced by URL, which libxml2 refuses to fetch.
# That refusal is harmless but noisy, so the notices are filtered out here.
if ! xmlstarlet val -q "${USER_CONFIG}" 2>/dev/null; then
    bashio::log.error "Your traccar.xml is not valid XML:"
    xmlstarlet val -e "${USER_CONFIG}" 2>&1 \
        | grep -vE 'properties\.dtd|network entity' >&2 || true
    bashio::exit.nok "Please correct the errors above and restart the app"
fi

# Without a <properties> root element, every setting in the file would be
# silently ignored, which is a lot harder to spot than an upfront error.
if ! xmlstarlet sel -Q -t -c "/properties" "${USER_CONFIG}" 2>/dev/null; then
    bashio::log.error "Your traccar.xml has no <properties> root element,"
    bashio::log.error "which means none of your settings can be applied."
    bashio::exit.nok "Please correct your traccar.xml and restart the app"
fi
