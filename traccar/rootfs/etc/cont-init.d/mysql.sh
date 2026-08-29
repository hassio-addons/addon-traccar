#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community App: Traccar
# Pre-configures the MySQL clients, if the service is available
# ==============================================================================
readonly CONFIG="/etc/traccar/defaults.xml"
readonly USER_CONFIG="/config/traccar.xml"

# Marks this installation as running on MySQL, so a database service that is
# temporarily unavailable is never mistaken for a brand new installation.
readonly MARKER="/data/.mysql"

declare host
declare password
declare port
declare username
declare url

# When the user points Traccar at a database of their own, the app stays out
# of the way completely.
if xmlstarlet sel -Q -t -c "/properties/entry[@key='database.driver']" \
    "${USER_CONFIG}" 2>/dev/null;
then
    exit 0
fi

# The database app can still be starting up, in which case the service shows
# up a little later. Silently continuing on the internal H2 database would
# make this installation look completely empty, so wait for it instead.
if bashio::fs.file_exists "${MARKER}" \
    && ! bashio::services.available "mysql"; then
    bashio::log.notice \
        "The MySQL service is not available yet, waiting up to 5 minutes..."
    for _ in {1..60}; do
        sleep 5
        if bashio::services.available "mysql"; then
            bashio::log.info "The MySQL service is available now, continuing"
            break
        fi
    done
fi

if ! bashio::services.available "mysql"; then

    # This installation has run on MySQL before. Starting on the empty H2
    # database would look exactly like all data has been lost, so don't.
    if bashio::fs.file_exists "${MARKER}"; then
        bashio::log.fatal
        bashio::log.fatal "The MySQL service is not available!"
        bashio::log.fatal
        bashio::log.fatal "Traccar stores its data in MySQL on this system,"
        bashio::log.fatal "but the database service is currently unavailable."
        bashio::log.fatal "Starting now would bring up an empty database, as"
        bashio::log.fatal "if all your users, devices and history were gone."
        bashio::log.fatal
        bashio::log.fatal "Your data is untouched. Please start the official"
        bashio::log.fatal "MariaDB app and restart this app afterwards."
        bashio::log.fatal
        bashio::exit.nok
    fi

    bashio::log.warning "Traccar is using the internal H2 default database!"
    bashio::log.warning "THIS IS NOT RECOMMENDED!!!"
    bashio::log.warning "Please install the official MariaDB app, to ensure"
    bashio::log.warning "you are using a solid database for Traccar."
    exit 0
fi

host=$(bashio::services "mysql" "host")
password=$(bashio::services "mysql" "password")
port=$(bashio::services "mysql" "port")
username=$(bashio::services "mysql" "username")

# Create database if not exists
echo "CREATE DATABASE IF NOT EXISTS traccar;" \
  | mysql --skip-ssl -h "${host}" -P "${port}" -u "${username}" -p"${password}"

# Update Traccar XML configuration for database. All four keys are shipped
# in the defaults, so they are updated in place; inserting new elements makes
# xmlstarlet parse the value as XML, which eats a "&" in, for example, a
# password. Updating an existing element escapes the value instead.
url="jdbc:mysql://${host}:${port}/traccar?serverTimezone=UTC&useSSL=false&allowMultiQueries=true&autoReconnect=true&useUnicode=yes&characterEncoding=UTF-8&sessionVariables=sql_mode=''"

xmlstarlet ed -L \
  -u "/properties/entry[@key='database.driver']" -v "com.mysql.cj.jdbc.Driver" \
  -u "/properties/entry[@key='database.url']" -v "${url}" \
  -u "/properties/entry[@key='database.user']" -v "${username}" \
  -u "/properties/entry[@key='database.password']" -v "${password}" \
  "${CONFIG}"

touch "${MARKER}"
