#!/bin/bash
#**************************************
# This Bash Script accomplishes the following task:
#------------------------------------
# 1. It updates the squirdGuard conf file according to the data/folders in squidGuard db directory.
# 2. It performs the following checks:
#    a) This script needs to be run as root. It checks the same.
#    b) Verifies the user input i.e. path of file/directory.	
#------------------------------------
# Script according to specific organisation's configuration.
# Tested on Fedora.
# Created by geeksScript | Kamal (http://geeksScript.com), Dated: 22-04-2013.
#**************************************

task0()
{

if [[ $UID -ne 0 ]]; then
	echo "$0 must be run as root";exit 1
else
	task1;
fi

}

task1()
{
	echo -n "Enter the absolute path for squirdGuard db directory:"
	read path
	if [ ! -d "$path" ]; then
		echo "Path does not exists, Try again"; task1
	else
		task2;
	fi
}

task2()
{
	echo -n "Enter the absolute path of squidGuard.conf file:"
	read loc
	if [ ! -f "$loc" ]; then
		echo "File does not exists, Try again"; task2
	else
		# Current date followed by current time.
		now=$(date +"%d-%m-%Y_%H-%M-%S")
		cp -i $loc $loc[$now];echo;
 		echo "Backup copy of current conf file saved as:$loc[$now]"
		task3;
	fi
}
		
task3()
{
echo "# CONFIG FILE FOR SQUIDGUARD

dbhome $path
logdir /var/log/squidGuard

#
# TIME RULES:
# abbrev for weekdays: 
# s = sun, m = mon, t =tue, w = wed, h = thu, f = fri, a = sat

#time workhours {
#	weekly mtwhf 08:00 - 16:30
#	date *-*-01  08:00 - 16:30
}
#
# REWRITE RULES:
#

#rew dmz {
#	s@://admin/@://admin.foo.bar.de/@i
#	s@://foo.bar.de/@://www.foo.bar.de/@i
#}

#
# SOURCE ADDRESSES:
#

#src admin {
#	ip		1.2.3.4 1.2.3.5
#	user		root foo bar
#	within 		workhours
#}

#src foo-clients {
#	ip		172.16.2.32-172.16.2.100 172.16.2.100 172.16.2.200
#}

#src bar-clients {
#	ip		172.16.4.0/26
#}
src home {
	ip 192.168.1.0/24
}

#
# DESTINATION CLASSES:
#

dest good {
}

dest local {
}
" > $loc
task4;
}

task4()
{
cd $path;
for dir in */; 
do 
	x=$(echo "$dir" | sed 's/\///g')
	echo  "dest $x {
	domainlist	blacklists/$x/domains
	urllist		blacklists/$x/urls
	expressionlist	blacklists/$x/expressions
	redirect 	http://admin.foo.bar.de/cgi/blocked?clientaddr=%a+clientname=%n+clientuser=%i+clientgroup=%s+targetgroup=%t+url=%u
}
" >> $loc

done
task5;
}

task5()
{
echo "acl {
#	admin {
#		pass	 any
#	}
#

#	foo-clients within workhours {
	
#	pass	 good !in-addr !adult any
#	} else {
#		pass any
#	}


#	bar-clients {
#		pass	local none
#	}


#	default {
#		pass	 local none
#		rewrite	 dmz
#		redirect http://admin.foo.bar.de/cgi/blocked?clientaddr=%a+clientname=%n+clientuser=%i+clientgroup=%s+targetgroup=%t+url=%u
#	}" >> $loc

echo -n "    home
	{
		pass" >> $loc
for dir in */; 
	do 
	{
		x=$(echo "$dir" | sed 's/\///g')
	
		echo -n " !$x" >> $loc
	}
done
echo -n " all
		redirect http://192.168.1.100/error/index.html
	}
	
}"  >> $loc
echo;echo "Data written to $loc"; exit 0
}

task0;
