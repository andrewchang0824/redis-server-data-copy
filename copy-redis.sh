#!/bin/bash

redisPath=`which redis-cli`
if [ -z $redisPath ]
then
	echo 'Please make sure the Redis Client is installed and set it to $PATH.'
	exit 1
fi

port=6379

while getopts f:t: option
do
	case "${option}" in
		f) from=${OPTARG};;
		t) to=${OPTARG};;
	esac
done

if [ -z "$from" ] || [ -z "$to" ]
then
	echo "Please assign the source and destination server."
	exit 1
fi

while true; do
	echo "From : ${from}"
	echo "To : ${to}"
    read -p "If it looks good, press y to continue, or n to exit:" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer y or n.";;
    esac
done

keystores=`redis-cli -c -h ${from} -p ${port} Keys "cache*"`
keystoresArray=($keystores)

for element in "${keystoresArray[@]}"
do
    value=`redis-cli -c -h ${from} -p ${port} GET ${element}`
    echo "Processing ${element}..."
    ret=`redis-cli -c -h ${to} -p ${port} SET ${element} "${value}"`
    echo "Result:${ret}"
    echo " "
    # echo "${value}" 
done
