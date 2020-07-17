# Sets Environment Variables from a Text File
set_envars () {
	source $1
	export $(cut -d= -f1 $1)
}
