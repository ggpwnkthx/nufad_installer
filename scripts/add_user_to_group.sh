# Add user to a group
in_group=0
#if [ ! -z "$(grep ^$2: /etc/group)" ]
#then
#	for $user in "$(grep ^$2: /etc/group | awk -F: '{print $4}' | sed 's/,/ /g')"
#	do
#		if [ "$user" == "$1" ]
#		then
#			in_group=1
#		fi
#	done
#fi

if [ $in_group -eq 0 ]
then
	if [ ! -z "$(command -v usermod)" ]
	then
		usermod -a -G $2 $1
	else
		addgroup $1 $2
	fi
fi
