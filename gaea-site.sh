#! /bin/bash

PROJECT_ROOT=$(dirname $(realpath $0))
GAEA_ENVARS_FILE='/tmp/envars.txt'

# Source functions file
source "$PROJECT_ROOT/functions.sh"

if [ -n "$1" ]; then

	if [ -n "$2" ]; then
		GAEA_DOMAIN="$2"
	else
		echo "Domain name is missing"
	fi

	while [ -n "$1" ]; do
		case "$1" in
			create)
				# Set environmental variables
				echo "Setting environmental variables..."
				gaea-db-new
				gaea-wp-new

				# Set up Apache configuration file
				echo "Setting up the Apache configuration file..."
				gaea-apache-cfg-file wordpress "test.$GAEA_DOMAIN"

				# Set up document root
				echo "Setting up website document root..."
				gaea-docroot $GAEA_DOMAIN

				# Enable the web site
				echo "Enabling the website..."
				a2ensite --quiet $GAEA_DOMAIN.conf
				systemctl reload apache2

				# Create the database
				echo "Creating the database..."
				gaea-db-create

				# Install WordPress
				echo "Installing WordPress..."
				gaea-wp-install
				;;
			stage)
				# Set environmental variables
				echo "Setting environmental variables..."
				gaea-db-new

				# Set up Apache configuration file
				echo "Setting up the Apache configuration file..."
				gaea-apache-cfg stage $GAEA_DOMAIN

				# Enable the web site
				echo "Enabling the website..."
				a2ensite --quiet "stage.$GAEA_DOMAIN.conf"
				systemctl reload apache2

				# Register the site
				echo "Registering the site..."
				gaea-site-register "stage.$GAEA_DOMAIN"

				# Create the database
				echo "Creating the database..."
				gaea-db-create
				gaea-db-register "stage.$GAEA_DOMAIN"

				# Migrate files and database
				echo "Copying files..."
				cp -r "/srv/www/$GAEA_DOMAIN" "/srv/www/stage.$GAEA_DOMAIN"
				echo "Dumping database..."
				gaea-db-dump $GAEA_DOMAIN
				echo "Populating database..."
				gaea-db-restore "stage.$GAEA_DOMAIN" $DB_BACKUP

				# Change site config and URL
				chown -R gabymg:gabymg /srv/www/stage.$GAEA_DOMAIN
				cd /srv/www/stage.$GAEA_DOMAIN
				echo "Creating new wp-config.php"
				wp config create --dbname=$GAEA_DB_NAME --dbuser=$GAEA_DB_USER --dbpass=$GAEA_DB_USERPASS --force
				echo "Changing site URL"
				wp search-replace "$GAEA_DOMAIN" "stage.$GAEA_DOMAIN" --skip-columns=guid
				wp option update home "http://stage.$GAEA_DOMAIN"
				wp option update siteurl "http://stage.$GAEA_DOMAIN"
				;;
			*)
				echo "Option not recognized"
				;;
		esac

		shift
	done
else
	echo "No parameters found"
fi


