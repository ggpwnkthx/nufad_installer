if [ "$0" != "/opt/nufad/scripts/bootstrap.sh" ]
then
	rm -R /opt/nufad
fi

# Ensure proper installation location
SCRIPTPATH=$(dirname "$0")
cp -RfT $SCRIPTPATH/../../nufad /opt/nufad

# Add nufad user
chmod +x $SCRIPTPATH/add_user.sh
$SCRIPTPATH/add_user.sh nufad

# Add nufad group
chmod +x $SCRIPTPATH/add_group.sh
$SCRIPTPATH/add_group.sh nufad

# Add nufad user to the nufad group
chmod +x $SCRIPTPATH/add_user_to_group.sh
$SCRIPTPATH/add_user_to_group.sh nufad nufad

# Figure out the local package manager
if [ ! -z "$(command -v apk)" ] ; then package_manager="apk" ; fi
if [ ! -z "$(command -v apt-get)" ] ; then package_manager="apt" ; fi
if [ ! -z "$(command -v yum)" ] ; then package_manager="yum" ; fi
if [ ! -z "$(command -v dnf)" ] ; then package_manager="dnf" ; fi

# Install bash and sudo
case $package_manager in
	"apk")
		apk update
		if [ -z "$(command -v sudo)" ]
		then
			apk add sudo
		fi
		if [ -z "$(command -v curl)" ]
		then
			apk add curl
		fi
		if [ -z "$(command -v nc)" ]
		then
			apk add netcat-openbsd
		fi
		if [ -z "$(echo 'dummy' | nc localhost 22 | grep SSH)" ]
		then
			apk add openssh
		fi
		;;
	"apt")
		if [ -z "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -1)" ]
		then
			apt-get update
		fi
		while [ "$(dpkg -s curl 2>/dev/null | grep Status | awk '{print $2}')" != "install" ]
		do
			apt-get install -y curl
		done
		while [ "$(dpkg -s sudo 2>/dev/null | grep Status | awk '{print $2}')" != "install" ]
		do
			apt-get install -y sudo
		done
		while [ "$(dpkg -s netcat 2>/dev/null | grep Status | awk '{print $2}')" != "install" ]
		do
			apt-get install -y netcat
		done
		if [ -z "$(echo 'dummy' | nc localhost 22 | grep SSH)" ]
		then
			apt-get install -y openssh-server
		fi
		;;
	"yum")
		yum update -y
		yum install -y sudo curl nc
		if [ -z "$(echo 'dummy' | nc localhost 22 | grep SSH)" ]
		then
			yum install -y openssh
		fi
		;;
	"dnf")
		dnf -y install sudo curl nmap
		if [ -z "$(echo 'dummy' | nc localhost 22 | grep SSH)" ]
		then
			dnf -y install openssh
		fi
		;;
	*)
		echo "Package manager not recognized."
		exit 2
		;;
esac

# Ensure the sudo group exists
$SCRIPTPATH/add_group.sh sudo
# Add nufad to the sudo group
$SCRIPTPATH/add_user_to_group.sh nufad sudo

echo "nufad ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nufad
chown -R nufad:nufad /opt/nufad
chmod -R 764 /opt/nufad
