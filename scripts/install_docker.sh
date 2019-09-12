#!/bin/sh
SCRIPTPATH=$(dirname "$0")

if [ -z "$(command -v docker)" ]
then
	echo "Installing Docker..."
	
	DISTRO=$(echo $(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 || uname -om) | awk '{print tolower($1)}')
	if [ ! -z "$(echo $DISTRO | grep pretty_name)" ]
	then
		DISTRO=$(echo $DISTRO | awk -F= '{gsub("\"","",$2)}{print $2}' | awk '{print tolower($1)}')
	fi
	
	# Figure out the local package manager
	if [ ! -z "$(command -v apk)" ] ; then package_manager="apk" ; fi
	if [ ! -z "$(command -v apt-get)" ] ; then package_manager="apt" ; fi
	if [ ! -z "$(command -v yum)" ] ; then package_manager="yum" ; fi
	if [ ! -z "$(command -v dnf)" ] ; then package_manager="dnf" ; fi

	# Install Docker
	case $package_manager in
		"apk")
			if [ -z "$(cat /etc/apk/repositories | grep community)" ]
			then
				ALPINE_VERSION=$(cat /etc/*-release | grep PRETTY_NAME | awk -F= '{gsub("\"","",$2)}{print $2}' | awk '{print $3}')
				echo http://dl-cdn.alpinelinux.org/alpine/$ALPINE_VERSION/community | sudo tee -a /etc/apk/repositories
			else 
				sudo sed -i '/^#.*community/s/^#//' /etc/apk/repositories
			fi
			sudo apk update
			sudo apk add docker shadow
			sudo rc-update add docker boot
			;;
		"apt")
			while [ "$(dpkg -s docker-ce 2>/dev/null | grep Status | awk '{print $2}')" != "install" ]
			do
				if [ -z "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -1)" ]
				then
					sudo apt-get update
				fi
				sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
				if [ -z "$(cat /etc/apt/sources.list | grep -v ^# | grep download.docker)" ]
				then
					curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo apt-key add -
					sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable"
					sudo apt-get update
				fi
				sudo apt-get install -y docker-ce
			done
			;;
		"yum")
			sudo yum install -y yum-utils device-mapper-persistent-data lvm2 curl
			sudo yum-config-manager --add-repo  https://download.docker.com/linux/$DISTRO/docker-ce.repo
			sudo yum -y install docker-ce
			;;
		"dnf")
			sudo dnf -y install dnf-plugins-core curl
			sudo dnf config-manager --add-repo https://download.docker.com/linux/$DISTRO/docker-ce.repo
			sudo dnf -y install docker-ce
			;;
		*)
			echo "Package manager not recognized."
			exit 1
			;;
	esac
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
