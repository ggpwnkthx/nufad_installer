#!/bin/sh

adduser --disabled-password --gecos "" --uid $DUID appuser
adduser appuser shadow
adduser appuser sudo
echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appuser

DOCKER_BRIDGE=$(printf "%d." $(awk '$2 == "00000000" {print $3}' /proc/net/route | sed 's/../0x& /g' | tr ' ' '\n' | tac) | sed 's/\.$/\n/')
if [ -z "$(grep 'DOCKER_BRIDGE=' /app/configs/app.ini)" ]
then
	echo "DOCKER_BRIDGE=\"$DOCKER_BRIDGE\"" >> /app/configs/app.ini
else
	sed -i "s/^\(DOCKER_BRIDGE\s*=\s*\).*\$/\1\"$DOCKER_BRIDGE\"/" /app/configs/app.ini
fi

MUID=$(hostname -s)
if [ -z "$(grep 'MUID=' /app/configs/app.ini)" ]
then
	echo MUID=\"$MUID\" >> /app/configs/app.ini
else
	sed -i 's/^\(MUID\s*=\s*\).*\$/\1"$MUID"/' /app/configs/app.ini
fi

export DOCKER_BRIDGE
export MUID

/usr/bin/supervisord
