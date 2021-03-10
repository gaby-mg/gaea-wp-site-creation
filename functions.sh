# Creates a random alphanumric string of the given length
gaea-random-string () {
	CHARSET="a-zA-Z0-9"
	LENGTH=$1

	< /dev/urandom tr -dc $CHARSET | head -c $LENGTH
}


gaea-random-password () {
	CHARSET="a-zA-Z0-9-_!@#$%^&*()_+{}|:<>?="
	LENGTH=$1

	< /dev/urandom tr -dc $CHARSET | head -c $LENGTH
}

# Checks if a database with a given name already exists
gaea-db-exists () {

	local IS_DB_CREATED=$( mysql -u root --skip-column-names -e "SELECT CASE WHEN EXISTS ( SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$1' ) THEN '0' ELSE '1' END" )

	if [ "$IS_DB_CREATED" = '0' ]; then
		return 0
	fi

	return 1
}

# Finds a unique database and password
gaea-db-new () {
	GAEA_DB_NAME="$( gaea-random-string 20 )"
	GAEA_DB_USER=$GAEA_DB_NAME'_'$( gaea-random-string 10 )
	GAEA_DB_USERPASS="$( gaea-random-password 18 )"

	while [ $( gaea-db-exists $DB_NAME ) ]
	do
		DB_NAME="$( gaea-random-string 20 )"
	done

	echo 'GAEA_DB_NAME="'$GAEA_DB_NAME'"' >> "$GAEA_ENVARS_FILE"
	echo 'GAEA_DB_USER="'$GAEA_DB_USER'"' >> "$GAEA_ENVARS_FILE"
	echo 'GAEA_DB_USERPASS="'$GAEA_DB_USERPASS'"' >> "$GAEA_ENVARS_FILE"
}


# Creates a database and a user with all permissions
#
# gaea-db-create dbname dbuser dbuserpass
gaea-db-create () {
	
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS $GAEA_DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"

	mysql -u root -e "GRANT ALL ON $GAEA_DB_NAME.* TO '$GAEA_DB_USER'@'localhost' IDENTIFIED BY '$GAEA_DB_USERPASS'"
}

gaea-apache-cfg-file-wp () {
	local TMP_FILE='/tmp/gaea-apache-config.txt'
	cat > $TMP_FILE <<-EOF
	<VirtualHost *:80>
        	ServerName test.$GAEA_DOMAIN

        	ServerAdmin hosting@gabymg.es
        	DocumentRoot /srv/www/$GAEA_DOMAIN
        	ErrorLog \${APACHE_LOG_DIR}/error.log
        	CustomLog \${APACHE_LOG_DIR}/access.log combined

        	# Enable .htacces Overrides
        	<Directory /srv/www/$GAEA_DOMAIN>
                	AllowOverride All
        	</Directory>
	</VirtualHost>
	EOF
}

# Generates an Apache config file for a given domain
gaea-apache-cfg-file () {
	local APACHE_CONFIG_FILE="/etc/apache2/sites-available/$GAEA_DOMAIN.conf"
	local TMP_FILE='/tmp/gaea-apache-config.txt'

	case "$1" in
		wordpress)
			gaea-apache-cfg-file-wp
			;;
	esac

	cp "$TMP_FILE" "$APACHE_CONFIG_FILE"
	rm $TMP_FILE
}

gaea-docroot () {
	local DIRECTORY="/srv/www/$GAEA_DOMAIN"
	mkdir "$DIRECTORY"

	echo "Hello, World!" > "$DIRECTORY/index.html"

	chown -R gabymg:gabymg $DIRECTORY
}

gaea-wp-new () {
	GAEA_WP_ADMIN="$( gaea-random-string 8 )"
	GAEA_WP_ADMIN_PASSWORD="$( gaea-random-password 18 )"
	GAEA_WP_ADMIN_EMAIL='wordpress@gabymg.es'

	echo 'GAEA_WP_ADMIN="'$GAEA_WP_ADMIN'"' >> "$GAEA_ENVARS_FILE"
	echo 'GAEA_WP_ADMIN_PASSWORD="'$GAEA_WP_ADMIN_PASSWORD'"' >> "$GAEA_ENVARS_FILE"
	echo 'GAEA_WP_ADMIN_EMAIL="'$GAEA_WP_ADMIN_EMAIL'"' >> "$GAEA_ENVARS_FILE"
}


gaea-wp-install () {

	local GAEA_LOCALE='es_ES'

	rm /srv/www/$GAEA_DOMAIN/index.html

	# Change ownership in order to use WP-CLI
	sudo chown -R gabymg:gabymg /srv/www/$GAEA_DOMAIN
	
	# Download WordPress
	sudo -u gabymg -i -- wp core download --locale=es_ES --path=/srv/www/$GAEA_DOMAIN
	touch /srv/www/$GAEA_DOMAIN/.htaccess

	# Create wp-config.php
	sudo -u gabymg -i -- wp config create --dbname=$GAEA_DB_NAME --dbuser=$GAEA_DB_USER --dbpass=$GAEA_DB_USERPASS --locale=$GAEA_LOCALE --path=/srv/www/$GAEA_DOMAIN

	# Install the site
	sudo -u gabymg -i -- wp core install --url=test.$GAEA_DOMAIN --title=$GAEA_TITLE --admin_user=$GAEA_WP_ADMIN --admin_email=$GAEA_WP_ADMIN_EMAIL --admin_password=$GAEA_WP_ADMIN_PASSWORD --path=/srv/www/$GAEA_DOMAIN
}
