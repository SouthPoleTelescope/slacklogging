#!/bin/bash
# slacklogger.sh
# by Joshua Montgomery 2016-10-12

# Purpose:
#  Download slack history then convert it into static HTML files

##################################
# environment variables
START=$(date +%s)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
version="1.0"
author="Joshua Montgomery (Joshua.J.Montgomery@gmail.com)"
date="2016-10-12"
usage="slacklogger by $author
	Version: $version
	Last updated date: $date

Usage: 
	slacklogger.sh -t token [options]

	TOKEN is the only required variable. Use \"slack-backup.sh --setup\" first before attempting to use the main body of this script.


Options:

	-h | --help 
		Display this help message. 

	-s | --setup 
		Run the software setup and check steps. This can take 1 - 5 minutes to execute.

	-t | --slack-token-file  FILE
		Text FILE containing the Slack API token. 

	-T | --slack-token TOKEN 
		Slack token embedded into the command parameters.
	NOTE: Token can be generated here: https://api.slack.com/web

	-o | --output DIRECTORY
		Base directory where the json, html, and log files will be saved. 

	-w | --bypass-warnings 
		Automatically continue even if warnings occur during setup."


printf "slacklogger v%s by %s\n\n" "$version" " $author"
##################################


##################################
# read input from command line
# Use > 0 to consume one or more arguments per pass in the loop (e.g. some arguments don't have a corresponding value to go with it such as in the --default example).
slack_token="x"
setup=false
help=false
output_directory='x'

while [[ $# > 0 ]]
 do
	key="$1"
	case $key in
		-t|--slack-token-file)
			slack_token="`cat $2`"
			shift # past argument
		;;

		-T|--slack-token)
			slack_token="$2"
			shift # past argument
		;;

		-h|--help)
			help=true
		;;

		-w|--bypass-warnings)
			cont=true
		;;

		-s|--setup)
			setup=true
		;;

		-o|--output)
			output_directory="$2"
		;;

		*) # unknown option
		;;
	esac
	shift # past argument or value
done
##################################


##################################
# check for input errors and fail
if ( $help )
 then
	printf "%s" "$usage"
	printf "\n"
	exit 200
else #prep the folders
	printf "Output Directory is: ${output_directory} \n"
	printf "Slack Token is: ${slack_token}\n\n"
	directory=$output_directory
	logs=$directory/logs
	json_exports=$directory/json_exports
	static_build=$directory/static_build
	mkdir -p $directory $logs $json_exports $static_build
fi

if ( $setup )
 then
	printf "Performing software updates/installs to make sure you have everything we need, then we'll get started.\n"
		#apt-get -y install php5-common php5-cli wget  1>${DIR}/setup1.log 2>&1
		#wget -qO- https://deb.nodesource.com/setup_4.x | bash - 1>${DIR}/setup2.log 2>&1
		#apt-get -y install nodejs 1>${DIR}/setup3.log 2>&1
		#wget -qO- https://deb.nodesource.com/setup_6.x | bash - 1>${DIR}/setup4.log 2>&1
		#apt-get -y install nodejs 1>${DIR}/setup5.log 2>&1
		#npm install npm -g 1>${DIR}/setup6.log 2>&1
		cd ${DIR}/slack-history-export
		npm install . 1>${DIR}/setup.log 
	printf "\n"
	exit 200
fi

# Housecleaning
rm -r ${static_build}/* &>>${DIR}/run.log
cd $json_exports;
rm -r ${json_exports}/* &>>${DIR}/run.log

# Run our modified version of the slack-history-export tool
# This has been modified to make more human readable end products
# and keep the installation (more) local and self-contained.
${DIR}/slack-history-export/bin/cli.js -t ${slack_token} -c "#all" -g "#all";

printf "\nUpdating the following Channels:\n"
for i in *.json; do
	mydir="${i%.json}"
	echo $mydir
	mkdir "${mydir}"
	mv $i "${mydir}"/$i
done

# Pull down some additional files we need from the slack API directoy
curl -s --output users.json --url https://slack.com/api/users.list?token=${slack_token}&pretty=1 &>>${DIR}/run.log;
curl -s --output channels.json --url https://slack.com/api/channels.list?token=${slack_token}&pretty=1 &>>${DIR}/run.log;
sleep 10s;

printf "\nBuilding the locally hosted pages from JSON.\n"
# serve the HTML locally using this handy app that I monkeyed with
python ${DIR}/slack-export-viewer/app.py -z ${json_exports} --no-browser & # &>${DIR}/slack-export-viewer.log & 
FLASK_PID=$!;
sleep 10s;

printf "\nPulling slacklogging into static HTML.\n"

# Pull down that locally served website into static HTML files
wget -q -P ${static_build} -mpck --user-agent="" -e robots=off --wait 1 -E -p -k http://localhost:5000 &>>${DIR}/run.log;

# Clean up
mv ${static_build}/localhost:5000/* ${static_build}/
rm -r ${static_build}/localhost:5000
kill $FLASK_PID
printf "\nFlask Server shutdown, cleaning up\n"

printf "\nSuccess. Static pages available at ${static_build}\n"
