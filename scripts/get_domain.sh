#!/bin/bash

domain=$(hostname -d)
if [ -z "$domain" ]
then
	if [ ! -z "$(command -v domainname)" ]
	then
	domain=$(domainname)
	fi
fi
if [ "$domain" == "(none)" -o -z "$domain" ]
then
	if [ ! -z "$(command -v nisdomainname)" ]
	then
		domain=$(nisdomainname)
	fi
fi
if [ "$domain" == "nisdomainname: Local domain name not set" -o -z "$domain" -o "$domain" == "(none)" ]
then
	if [ ! -z "$(command -v ypdomainname)" ]
	then
		domain=$(ypdomainname)
	fi
fi
if [ "$domain" == "ypdomainname: Local domain name not set" -o "$domain" == "nisdomainname: Local domain name not set" -o -z "$domain" -o "$domain" == "(none)" ]
then
	if [ ! -z "$(command -v dnsdomainname)" ]
	then
		domain=$(dnsdomainname)
	fi
fi

echo $domain