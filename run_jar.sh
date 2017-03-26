#!/bin/bash
clear
SERVICE="/u01/callsign/mainthread/mainthread.jar"
DIR="/u01/callsign/mainthread"
r=`tput setaf 1`
r1=`tput setaf 2`
N=`tput sgr0`

function usage () {
    echo "Usage:";
    echo "manage <command>";
    echo "       <command>: start | stop | restart | status";
}

function checksrv () {
    echo `ps -ef | grep "$1" | wc -l`;
}

function showsrv () {
    ps -ef | grep "$1" | grep java;
}

function killprc () {
    if [ $# -le 2 ]
    then
        echo "Unknow process ID";
    else
        pid=$2;
        #echo "Pid: $2";
        kill  $2;
    fi
}

function show_prompt() {
STOPTIMEOUT=5
    while [ $STOPTIMEOUT -gt 0 ]; do
        sleep 1
        let STOPTIMEOUT=${STOPTIMEOUT}-1
	awk 'BEGIN {while (c++<1) printf "* "}'
        done
echo "";
}

function show_vnteleco(){ 
echo "|----------------------------------------------------|";
echo "|                     _       _                      |";
echo "|        __   ___ __ | |_ ___| | ___  ___ ___        |";
echo "|        \ \ / / '_ \| __/ _ \ |/ _ \/ __/ _ \       |";
echo "|         \ V /| | | | ||  __/ |  __/ (_| (_) |      |";
echo "|          \_/ |_| |_|\__\___|_|\___|\___\___/       |";
echo "|                                                    |";
echo "|                 CONTACT TO SUPPORTED               |";
echo "|              Email:   support@vnteleco.net         |";
echo "|             Website: http://www.vnteleco.net       |";
echo "|----------------------------------------------------|";
}
function stopsrv () {
show_vnteleco ;
    isrunning=`checksrv $1`;
        #echo $isrunning;
        if [ $isrunning -le 1 ]
        then
		echo "Stop module $1 ....";
		show_prompt;
		echo "Module $1 is ${r1}[NOT Running]${N}";
        else
	pline=`showsrv $1`;
	echo "Stop module $1 ....";
	killprc $pline;
	show_prompt ;
	fi
	isrunning=`checksrv $1`;
	if [ $isrunning -le 1 ]
        then
                echo "Module $1 stop ${r1}[Success]${N}";
	else
	echo "Module $1 stop ${r}[NOT Success]${N}";
	fi
}

function startsrv () {
show_vnteleco ;
    isrunning=`checksrv $1`;
        #echo $isrunning;
        if [ $isrunning -gt 1 ]
        then
                        echo "Starting module $1 ....";
                	show_prompt;
                	echo "Module $1 is ${r1}[Running]${N}";
        else

        echo "Starting module $1 ...";
	show_prompt;
	cd $DIR
	nohup java -jar $1 1> /dev/null 2>/dev/null &
	echo "Module $1 start is ${r1}[Success]${N}";	
	exit;
	fi
	echo "Module $1 start is ${r1}[Success]${N}";

	
}

#echo $#;
if [ $# -ne 1 ]
then
    usage;
    exit;
fi

cmd=$1;

if [[ "$cmd" != "start" && "$cmd" != "stop" && "$cmd" != "status" && "$cmd" != "restart" ]]
then
        usage;
        exit;
fi

if [ "$cmd" = "status" ]
then
        isrunning=`checksrv $SERVICE`;
        #echo $isrunning;
        if [ $isrunning -gt 1 ]
        then
		show_vnteleco ;
                echo "Module $SERVICE is running ...";
                showsrv $SERVICE;
                exit;
    	else
		show_vnteleco ;
        	echo "Module $SERVICE is not running ...";
        fi

    exit;
fi

if [ "$cmd" = "start" ]
then
    startsrv $SERVICE;
    exit;
fi

if [ "$cmd" = "stop" ]
then
    stopsrv $SERVICE;
    exit;
fi

if [ "$cmd" = "restart" ]
then
    stopsrv $SERVICE;
    startsrv $SERVICE;
fi
