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

testCreatesDatabase () {
	DB_NAME=bar
	gaea-db-create $DB_NAME

	IS_DB_CREATED=$( mysql -u root --skip-column-names -e "SELECT CASE WHEN EXISTS ( SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$DB_NAME' ) THEN '0' ELSE '1' END" )
	assertTrue "$IS_DB_CREATED"
}

# Load shUnit2
. "/usr/local/src/shunit2/shunit2"
