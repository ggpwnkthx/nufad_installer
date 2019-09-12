if [ "$0" != "/opt/nufad/start.sh" ]
then
	SCRIPTPATH=$(dirname "$0")/scripts
	chmod +x "$SCRIPTPATH/bootstrap.sh"
	echo "Bootstrapping as root..."
	su root -c "$SCRIPTPATH/bootstrap.sh && su nufad -c '/opt/nufad/start.sh'"
	exit 1
fi

# Gate keeper
if [[ "$USER" != "nufad" ]]
then
	sudo su nufad -c $0
	exit 1
fi

#
# At this point we can safely assume we are:
#  * running in a BASH environment
#  * we are running the script /opt/nufad/start.sh
#  * that we are running as the user "nufad"
#

# Set absolute script directory path
SCRIPTPATH=/opt/nufad/scripts
APPPATH=/opt/nufad/app

# Make sure the stop script is executable
chmod +x /opt/nufad/stop.sh

# Build
chmod +x $SCRIPTPATH/build.sh
$SCRIPTPATH/build.sh

# Get the domain name of the local host, if it exists
chmod +x $SCRIPTPATH/get_domain.sh
domain=$($SCRIPTPATH/get_domain.sh)
if [ -z "$domain" ] ; then domain="local" ; fi

# Find the IP address of the Docker Bridge
bridge_ip=$()

# Run the container with app persistence
docker_cmd="docker run -d \
	--cap-add=SYS_ADMIN \
	--hostname $(cat /proc/sys/kernel/random/uuid).nufad.$domain \
	-p 443:443 \
	-e DUID=$(id -u nufad) \
	-e NUFAD_PASSWD=password \
	-v $APPPATH:/app \
	nufad"
if [ -z "$(id -Gn | grep docker)" ]
then
	sudo sg docker -c "$docker_cmd"
else
	$docker_cmd
fi
