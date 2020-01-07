# Add group
if [ -z "$(cat /etc/group | grep ^$1:)" ]
then
	if [ -z "$(command -v addgroup)" ]
	then
		if [ -f "/usr/sbin/addgroup" ]
		then
			/usr/sbin/addgroup $1
		else
			groupadd $1
		fi
	else
		addgroup $1
	fi
fi
