#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Traccar
# Pre-configures the MySQL clients, if the service is available
# ==============================================================================
readonly CONFIG="/etc/traccar/hassio.xml"
declare host
declare password
declare port
declare username
declare url

if bashio::fs.file_exists "/config/traccar.xml"; then
  if xmlstarlet sel -t -v "/properties/entry[@key='database.driver']" \
    "/config/traccar.xml" >/dev/null 2>&1;
  then
    exit 0
  fi
fi

if bashio::services.available "mysql"; then
  host=$(bashio::services "mysql" "host")
  password=$(bashio::services "mysql" "password")
  port=$(bashio::services "mysql" "port")
  username=$(bashio::services "mysql" "username")

  # Create database if not exists
  echo "CREATE DATABASE IF NOT EXISTS traccar;" \
    | mysql -h "${host}" -P "${port}" -u "${username}" -p"${password}"

  # Update Traccar XML configuration for database
  xmlstarlet ed -L -s /properties \
    -t elem -n entry_placeholder -v "com.mysql.jdbc.Driver" \
      -i //entry_placeholder -t attr -n "key" -v "database.driver" \
    -r //entry_placeholder -v entry \
    "${CONFIG}"

  url="jdbc:mysql://${host}:${port}/traccar?serverTimezone=UTC&amp;useSSL=false&amp;allowMultiQueries=true&amp;autoReconnect=true&amp;useUnicode=yes&amp;characterEncoding=UTF-8&amp;sessionVariables=sql_mode=''"
  xmlstarlet ed -L -s /properties \
    -t elem -n entry_placeholder -v "${url}" \
      -i //entry_placeholder -t attr -n "key" -v "database.url" \
    -r //entry_placeholder -v entry \
    "${CONFIG}"

  xmlstarlet ed -L -s /properties \
    -t elem -n entry_placeholder -v "${username}" \
      -i //entry_placeholder -t attr -n "key" -v "database.user" \
    -r //entry_placeholder -v entry \
    "${CONFIG}"

  xmlstarlet ed -L -s /properties \
    -t elem -n entry_placeholder -v "${password}" \
      -i //entry_placeholder -t attr -n "key" -v "database.password" \
    -r //entry_placeholder -v entry \
    "${CONFIG}"
else
  bashio::log.warning "Traccar is using the internal H2 default database!"
  bashio::log.warning "THIS IS NOT RECOMMENDED!!!"
  bashio::log.warning "Please install the official MariaDB add-on, to ensure"
  bashio::log.warning "you are using a solid database for Traccar."
fi
