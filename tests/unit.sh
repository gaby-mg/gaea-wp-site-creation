#! /bin/bash

# Run only the functions that we test
source "../functions.sh"

# Test we can set environment variables from key/value pairs exported from a
# text file
testSetsEnvVarsFromTextFile () {
	FILE=/tmp/envars.txt

	cat > $FILE <<- EOM
	DOMAIN=example.com
	DB=foo
	EOM

	gaea-set-envars /tmp/envars.txt

	assertSame 'example.com' "$DOMAIN"
	assertSame 'foo' "$DB"
}

testCreatesARandomString () {
	local LENGTH=5
	local RANDOM_STRING="$( gaea-random-string $LENGTH )"
	
	assertNotNull "$RANDOM_STRING"
}

testFindsNewDatabaseAdnUserNames () {
	gaea-db-create 'foo' 'bar' '12345678a-zA-Z'
	DB_NAME="$( gaea-db-new )"

	IS_ALREADY_A_DB_THERE=$( mysql -u root --skip-column-names -e "SELECT CASE WHEN EXISTS ( SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME' ) THEN '0' ELSE '1' END" )

	assertFalse "A database with that name already exists" "$IS_ALREADY_A_DB_THERE"
}

testCreatesDatabaseAndUser () {
	local DB_NAME=foo
	local DB_USER=bar
	local DB_USERPASS='12345678a-zA-Z'
	local DB_PERMS="GRANT ALL PRIVILEGES"

	gaea-db-create $DB_NAME $DB_USER $DB_USERPASS

	IS_DB_CREATED=$( mysql -u root --skip-column-names -e "SELECT CASE WHEN EXISTS ( SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME' ) THEN '0' ELSE '1' END" )

	IS_DBUSER_CREATED=$( mysql -u root --skip-column-names -e "SELECT CASE WHEN EXISTS ( SELECT * FROM mysql.user WHERE User = '$DB_USER' ) THEN '0' ELSE '1' END" )

	DB_USER_PERMS=$( mysql -u root --skip-column-names -e "SHOW GRANTS FOR '$DB_USER'@'localhost'" )
	
	
	assertTrue "The database wasn't created" "$IS_DB_CREATED"
	assertTrue "The database user wasn't created" "$IS_DBUSER_CREATED"
	assertContains "The database user hasn't required permissions" "$DB_USER_PERMS" "$DB_PERMS"

}

oneTimeTearDown () {
	local DB_NAME='foo'
	local DB_USER='bar'

	mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
	mysql -u root -e "DROP USER IF EXISTS $DB_USER@localhost"
}

# Load shUnit2
. "/usr/local/src/shunit2/shunit2"
