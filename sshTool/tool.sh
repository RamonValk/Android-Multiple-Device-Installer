#!/bin/sh
sshServer=move4mobile@192.168.13.97
echo "Checking arguments..."
if [[ "$1" -eq "-a" ]] && [[ "$2" == *".apk" ]]; then
	echo "-a flag found, Copying over to server..."
	scp $2 $sshServer:/tmp
	app="$(echo $2 | rev | cut -d'/' -f-1 | rev)"
	
	shift 2
	ssh $sshServer "PATH=/usr/local/bin:$PATH && /usr/local/bin/mdInstaller -a $app $@"
	echo "$@"
fi
ssh $sshServer "PATH=/usr/local/bin:$PATH && /usr/local/bin/mdInstaller $@"