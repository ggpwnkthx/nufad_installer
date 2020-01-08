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
	sed -i "s/^\(MUID\s*=\s*\).*\$/\1\"$MUID\"/" /app/configs/app.ini
fi

# Create 20 year SSL certificate (if one does not exist) for HTTPS. 
# !!!! You SHOULD DEFINITELY use your own trusted certificate. Not this auto-generated one. !!!!
if [ ! -d /app/certs ]
then
	mkdir /app/certs
fi
if [ ! -f /app/certs/ssl.crt ]
then
	openssl genrsa -out /app/certs/ssl.pass.key 2048
	openssl rsa -in /app/certs/ssl.pass.key -out /app/certs/ssl.key
	rm /app/certs/ssl.pass.key
	openssl req -new -key /app/certs/ssl.key -out /app/certs/ssl.csr \
		-subj "/C=NA/ST=NA/"
	openssl x509 -req -days 7120 -in /app/certs/ssl.csr -signkey /app/certs/ssl.key -out /app/certs/ssl.crt
fi

export DOCKER_BRIDGE
export MUID

/usr/bin/supervisord
