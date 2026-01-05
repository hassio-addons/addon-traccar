#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Traccar
# Pre-configures the MySQL clients, if the service is available
# ==============================================================================
readonly CONFIG="/etc/traccar/traccar.xml"
declare host
declare password
declare port
declare username
declare url

if bashio::services.available "mysql"; then
  host=$(bashio::services "mysql" "host")
  password=$(bashio::services "mysql" "password")
  port=$(bashio::services "mysql" "port")
  username=$(bashio::services "mysql" "username")

  # Create database if not exists
  echo "CREATE DATABASE IF NOT EXISTS traccar;" \
    | mysql --skip-ssl -h "${host}" -P "${port}" -u "${username}" -p"${password}"

  # Update Traccar XML configuration for database
  xmlstarlet ed -L -u "/properties/entry[@key='database.driver']" \
    -v "com.mysql.cj.jdbc.Driver" \
    "${CONFIG}"

  url="jdbc:mysql://${host}:${port}/traccar?serverTimezone=UTC&useSSL=false&allowMultiQueries=true&autoReconnect=true&useUnicode=yes&characterEncoding=UTF-8&sessionVariables=sql_mode=''"
  xmlstarlet ed -L -u "/properties/entry[@key='database.url']" -v "${url}" \
    "${CONFIG}"

  xmlstarlet ed -L -u "/properties/entry[@key='database.user']" \
    -v "${username}" \
    "${CONFIG}"

  xmlstarlet ed -L -u "/properties/entry[@key='database.password']" \
    -v "${password}" \
    "${CONFIG}"
else
  bashio::log.warning "Traccar is using the internal H2 default database!"
  bashio::log.warning "THIS IS NOT RECOMMENDED!!!"
  bashio::log.warning "Please install the official MariaDB add-on, to ensure"
  bashio::log.warning "you are using a solid database for Traccar."
fi
