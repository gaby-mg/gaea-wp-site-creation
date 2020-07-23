# Sets Environment Variables from a Text File
gaea-set-envars () {
	source $1
	export $(cut -d= -f1 $1)
}


# Creates a database and a user with all permissions
#
# gaea-db-create dbname dbuser dbuserpass
gaea-db-create () {
	
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS $1 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci"

	mysql -u root -e "GRANT ALL ON $1.* TO '$2'@'localhost' IDENTIFIED BY '$3'"
}
