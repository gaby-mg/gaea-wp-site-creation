#! /bin/bash

GAEA_ENVARS_FILE='/tmp/envars.txt'

# Source functions file
source "functions.sh"

if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		case "$1" in
			create)
				# Get environmental variables
				echo "Getting environmental variables..."
				gaea-db-new
				gaea-wp-new

				# Set environmental variables
				echo "Setting environmental variables..."
				gaea-set-envars "/tmp/envars.txt"

				# Set up Apache configuration file
				echo "Setting up the Apache configuration file..."
				gaea-apache-cfg-file 'wordpress'

				# Set up document root
				echo "Setting up website document root..."
				gaea-docroot

				# Start the web site
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
			*) echo "Option not recognized"
		esac

		shift
	done
else
	echo "No parameters found"
fi


