#! /bin/bash

# Run only the functions that we test
source ../functions.sh

# Test we can set environment variables from key/value pairs exported from a
# text file
testSetsEnvVarsFromTextFile () {
	FILE=/tmp/envars.txt

	cat > $FILE <<- EOM
	DOMAIN=example.com
	DB=foo
	EOM

	set_envars /tmp/envars.txt

	assertSame 'example.com' "$DOMAIN"
	assertSame 'foo' "$DB"
}	

# Load shUnit2
. "/usr/local/src/shunit2/shunit2"
