#!/bin/sh

if [[ "$USER" == "root" ]]
then
	echo "Do NOT run this as root."
	exit 2
fi

