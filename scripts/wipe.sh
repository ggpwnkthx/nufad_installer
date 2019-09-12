# Remove all nufad docker containers
containers=$(docker ps -a | grep nufad | awk '{print $1}')
for c in "$containers"
do
	docker kill $c
	docker rm $c
done

# Set reletive script path
APPPATH=/opt/nufad/app

# Clean up SSL files
rm $APPPATH/certs/* -f

# Clean up databases
rm -r $APPPATH/configs/databases -f
sudo rm -r $APPPATH/configs/packages -f

# Clean up log files
rm $APPPATH/supervisord.pid -f
rm $APPPATH/supervisord.log -f
rm $APPPATH/app.log -f
rm -r $APPPATH/logs -f

# Clean out any compiled python files
find $APPPATH/ -name "*.pyc" -type f -delete
find $APPPATH/ -name "__pycache__" -type d -delete

# Remove nufad docker image
docker rmi nufad