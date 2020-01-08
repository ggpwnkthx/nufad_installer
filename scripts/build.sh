# Set absolute paths
APPPATH=/opt/nufad/app
DOCKERPATH=/opt/nufad/docker
SCRIPTPATH=/opt/nufad/scripts

# Ensure docker is installed
chmod +x $SCRIPTPATH/install_docker.sh
$SCRIPTPATH/install_docker.sh

# Make sure app is available
git clone https://github.com/ggpwnkthx/nufad.git $APPPATH

# Make sure log folder exists
mkdir -p $APPPATH/logs/nufad
# Assure folder permissions for package configs
mkdir -p $APPPATH/configs/packages

# Set up SSH key to allow the app to communicate with the host system as the current user.
mkdir -p ~/.ssh
if [ ! -e ~/.ssh/id_rsa.pub ]
then
	ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub | tee -a ~/.ssh/authorized_keys
fi

# Define a default SSH user
mkdir -p $APPPATH/configs/packages/ssh/local
cp ~/.ssh/authorized_keys $APPPATH/configs/packages/ssh/local/nufad

# Build the Docker image
nufad_build="docker build -t nufad $DOCKERPATH/nufad"
if [ -z "$(sudo docker images | grep nufad)" ]
then
	if [ -z "$(id -Gn | grep docker)" ]
	then
		sudo sg docker -c "$nufad_build"
	else
		$nufad_build
	fi
fi
