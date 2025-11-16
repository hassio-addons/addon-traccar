#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Traccar
# Ensures the user configuration file is present
# ==============================================================================
declare host
declare password
declare port
declare username

# Migrate add-on data from the Home Assistant config folder,
# to the add-on configuration folder.
if ! bashio::fs.directory_exists '/config/traccar.xml' \
    && bashio::fs.file_exists '/homeassistant/traccar.xml'; then
    mv /homeassistant/traccar.xml /config/traccar.xml \
        || bashio::exit.nok "Failed to migrate Traccar configuration"
fi

if ! bashio::fs.file_exists "/config/traccar.xml"; then
    cp /etc/traccar/traccar.xml /config/traccar.xml
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
