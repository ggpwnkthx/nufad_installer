# Add user
if [ -z "$(cat /etc/shadow | grep nufad:)" ]
then
	ADDUSER_CMD="adduser"
	if [ ! -z "$(adduser -? 2>&1 | grep -E ^*--disabled-password)" ] ; then ADDUSER_CMD="$ADDUSER_CMD --disabled-password" ; fi
	if [ ! -z "$(adduser -? 2>&1 | grep -E ^*--gecos)" ] ; then ADDUSER_CMD="$ADDUSER_CMD --gecos ''" ; fi
	if [ ! -z "$(adduser -? 2>&1 | grep -E 'Don*.t assign a password')" ] ; then ADDUSER_CMD="$ADDUSER_CMD $(adduser -? 2>&1 | grep -E 'Don*.t assign a password' | awk '{print $1}')" ; fi
	echo $ADDUSER_CMD $1
	$ADDUSER_CMD $1
fi
