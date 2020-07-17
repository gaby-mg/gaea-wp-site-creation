#! /bin/bash

# Test provides a working web site with the text 'Hello world!'
testProvidesWorkingWebSite () {
	cd ..
	./siteCreation.sh /tmp/envars.txt
	cat /tmp/output.txt
	assertSame $? "Hello World!"
}

# Load shUnit2
. "/usr/local/src/shunit2/shunit2"
