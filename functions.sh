# Sets Environment Variables from a Text File
gaea-set-envars () {
	source $1
	export $(cut -d= -f1 $1)
}

# Creates a random alphanumric string of the given length
gaea-random-string () {
	CHARSET="a-zA-Z0-9"
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
	local DB_CREDENTIALS_FILE='/tmp/db-credentials.txt'
	local DB_NAME="$( gaea-random-string 20 )"
	local DB_USER="$( gaea-random-string 10 )"

	while [ $( gaea-db-exists $DB_NAME ) ]
	do
		DB_NAME="$( gaea-random-string 20 )"
	done

	touch "$DB_CREDENTIALS_FILE"
	
	echo "DB_NAME=$DB_NAME" > "$DB_CREDENTIALS_FILE"
	echo 'DB_USER='$DB_NAME'_'$DB_USER >> "$DB_CREDENTIALS_FILE"
}

# 


# Creates a database and a user with all permissions
#
# gaea-db-create dbname dbuser dbuserpass
gaea-db-create () {
	
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS $1 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"

	mysql -u root -e "GRANT ALL ON $1.* TO '$2'@'localhost' IDENTIFIED BY '$3'"
}
