# Remove all nufad docker containers
containers=$(docker ps -a | grep nufad | awk '{print $1}')
for c in "$containers"
do
	cid=$(docker kill $c)
done
echo "NUFAD has been stopped."

# Set reletive script path
APPPATH=/opt/nufad/app

# Clean up log files
rm $APPPATH/supervisord.pid -f
rm $APPPATH/supervisord.log -f
rm $APPPATH/app.log -f
rm -r $APPPATH/logs -f
echo "Log files have been deleted."

# Clean out any compiled python files
find $APPPATH/ -name "*.pyc" -type f -delete
find $APPPATH/ -name "__pycache__" -type d -delete
echo "Python cache has been cleared."

echo "NOTE: Sessions were preserved."

echo "To restart, use the following command:"
echo " > docker start $cid"