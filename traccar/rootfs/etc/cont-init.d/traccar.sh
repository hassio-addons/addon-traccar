#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community App: Traccar
# Ensures the user configuration file is present and builds the runtime config
# ==============================================================================
readonly DEFAULTS="/etc/traccar/hassio.xml"
readonly USER_CONFIG="/config/traccar.xml"
readonly RUNTIME_CONFIG="/var/run/traccar/traccar.xml"
declare host
declare key
declare password
declare port
declare username
declare value

# Migrate app data from the Home Assistant config folder,
# to the app configuration folder.
if ! bashio::fs.file_exists "${USER_CONFIG}" \
    && bashio::fs.file_exists '/homeassistant/traccar.xml'; then
    mv /homeassistant/traccar.xml "${USER_CONFIG}" \
        || bashio::exit.nok "Failed to migrate Traccar configuration"
fi

if ! bashio::fs.file_exists "${USER_CONFIG}"; then
    cp /etc/traccar/traccar.xml "${USER_CONFIG}"
else
    # Existing installation
    if bashio::services.available "mysql"; then
        # Make sure the database isn't locked
        host=$(bashio::services "mysql" "host")
        password=$(bashio::services "mysql" "password")
        port=$(bashio::services "mysql" "port")
        username=$(bashio::services "mysql" "username")

        echo "UPDATE DATABASECHANGELOGLOCK SET locked=0;" \
            | mysql --skip-ssl -h "${host}" -P "${port}" -u "${username}" -p"${password}" \
                traccar || true
    fi
fi

# Traccar dropped the "config.default" parameter in 6.2, so the app defaults
# and the user configuration are merged into a single runtime file instead.
mkdir -p "$(dirname "${RUNTIME_CONFIG}")"
cp "${DEFAULTS}" "${RUNTIME_CONFIG}"

# The properties DTD is referenced by URL, which libxml2 refuses to fetch.
# That refusal is harmless but noisy, so the notices are filtered out here.
if ! xmlstarlet val -q "${USER_CONFIG}" 2>/dev/null; then
    bashio::log.error "Your traccar.xml is not valid XML:"
    xmlstarlet val -e "${USER_CONFIG}" 2>&1 \
        | grep -vE 'properties\.dtd|network entity' >&2 || true
    bashio::exit.nok "Please correct the errors above and restart the app"
fi

while read -r key; do
    # Left over from older versions of this app; it no longer does anything.
    if [[ "${key}" == "config.default" ]]; then
        bashio::log.notice \
            "Ignoring obsolete 'config.default' in your traccar.xml," \
            "you can safely remove it"
        continue
    fi

    value=$(xmlstarlet sel -t -v "/properties/entry[@key='${key}']" \
        "${USER_CONFIG}" 2>/dev/null)

    if xmlstarlet sel -Q -t -c "/properties/entry[@key='${key}']" \
        "${RUNTIME_CONFIG}" 2>/dev/null; then
        xmlstarlet ed -L \
            -u "/properties/entry[@key='${key}']" -v "${value}" \
            "${RUNTIME_CONFIG}" 2>/dev/null
    else
        xmlstarlet ed -L -s /properties \
            -t elem -n entry_placeholder -v "${value}" \
                -i //entry_placeholder -t attr -n "key" -v "${key}" \
            -r //entry_placeholder -v entry \
            "${RUNTIME_CONFIG}" 2>/dev/null
    fi
done < <(xmlstarlet sel -t -m "/properties/entry" -v "@key" -n \
    "${USER_CONFIG}" 2>/dev/null)
