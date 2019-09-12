#!/bin/sh

docker_kill="docker kill $(docker ps | grep nufad | awk '{print $1}')"
if [ -z "$(id -Gn | grep docker)" ]
then
	sg docker -c $docker_kill
else
	$docker_kill
fi
