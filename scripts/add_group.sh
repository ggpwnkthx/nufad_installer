#Environment
if [ -z "$(echo $PATH | grep '/usr/sbin')" ]
then
	export PATH=/usr/sbin:$PATH
fi
# Add group
if [ -z "$(cat /etc/group | grep ^$1:)" ]
then
	if [ -z "$(command -v addgroup)" ]
	then
		groupadd $1
	else
		addgroup $1
	fi
fi
