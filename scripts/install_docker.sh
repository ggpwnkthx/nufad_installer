#!/bin/sh
SCRIPTPATH=$(dirname "$0")

if [ -z "$(command -v docker)" ]
then
	echo "Installing Docker..."
	
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
fi

# Start the docker service
if [ ! -z "$(command -v service)" ]
then
	sudo service docker start
fi

# Install docker-compose
if [ ! -f /usr/local/bin/docker-compose ]
then
	sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
fi
sudo chmod +x /usr/local/bin/docker-compose

# Check to make sure current user can run docker
echo "Adding $USER user to the docker group."
sudo $SCRIPTPATH/add_user_to_group.sh $USER docker
