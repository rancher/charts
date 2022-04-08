#!/bin/bash

statusCheck(){
local retries=0
# Max Timeout in seconds  default ~3600
local maxTimeOutInSeconds=$1
MaxRetries=$(( maxTimeOutInSeconds/10 ))
# Wait for DB to start 
sleep 30
until [ "`curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8082/router/api/v1/system/health`" == "200" ];
do
  echo Waiting for Artifactory to start --- sleeping for 10 seconds
  if [[ ${retries} -eq ${MaxRetries} ]]
  then 
    echo Failed to start.
    exit 1
  fi
  retries=$(( retries+1 ))
  sleep 10
done

sleep 20
echo "Artifactory started sucessfully...in Init Container"
echo "Stopping artifactory in Init Container..."
${scriptsPath}/artifactory.sh stop
echo "Exiting Init Container..."

}

scriptsPath="/opt/jfrog/artifactory/app/bin"
maxTimeOut=$2
bash ${scriptsPath}/migrate.sh $1
status=$?
if [[ ${status} -eq 1 && -f /tmp/error ]]; then
  echo "Migration is not supported ...Exiting Init Container"
  exit 1
elif [[ ${status} -eq 0 ]]; then
  echo "Waiting for Artifactory to start in Init Container"
  /entrypoint-artifactory.sh &
  statusCheck ${maxTimeOut}
else
  echo "Migration not necessary...Exiting Init Container"
  exit 0
fi