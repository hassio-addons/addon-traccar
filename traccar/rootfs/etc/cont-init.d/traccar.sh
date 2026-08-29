#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community App: Traccar
# Builds the runtime configuration Traccar is started with
# ==============================================================================
readonly DEFAULTS="/etc/traccar/defaults.xml"
readonly MERGE="/etc/traccar/merge.xslt"
readonly RUNTIME_CONFIG="/var/run/traccar/traccar.xml"
readonly USER_CONFIG="/config/traccar.xml"
declare error
declare host
declare password
declare port
declare username

if bashio::services.available "mysql"; then
    # Traccar can leave its schema migration locked when it is stopped
    # halfway through one, which blocks every start after that.
    host=$(bashio::services "mysql" "host")
    password=$(bashio::services "mysql" "password")
    port=$(bashio::services "mysql" "port")
    username=$(bashio::services "mysql" "username")

    echo "UPDATE DATABASECHANGELOGLOCK SET locked=0;" \
        | mysql --skip-ssl -h "${host}" -P "${port}" -u "${username}" \
            -p"${password}" traccar 2>/dev/null || true
fi

if xmlstarlet sel -Q -t -c "/properties/entry[@key='config.default']" \
    "${USER_CONFIG}" 2>/dev/null;
then
    # Left over from older versions of this app; it no longer does anything.
    bashio::log.notice \
        "Ignoring obsolete 'config.default' in your traccar.xml," \
        "you can safely remove it"
fi

# Traccar dropped the "config.default" parameter in 6.2, so the app defaults
# and the user configuration are merged into a single runtime file instead.
# The merge happens at the XML level, since passing the values through the
# shell escapes them a second time; the "&" in a JDBC connection URL would
# reach Traccar as a literal "&amp;".
mkdir -p "$(dirname "${RUNTIME_CONFIG}")"
if ! error=$(xmlstarlet tr "${MERGE}" -s "user=${USER_CONFIG}" \
    "${DEFAULTS}" 2>&1 >"${RUNTIME_CONFIG}");
then
    bashio::log.error "${error}"
    bashio::exit.nok "Failed to build the Traccar configuration"
fi
