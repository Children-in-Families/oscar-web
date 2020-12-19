#!/usr/bin/env bash

basedir=$(dirname $0)
currentVersion=$(${basedir}/getVersion.sh)

if [[ "${currentVersion}" == *-SNAPSHOT ]]
then
    newVersion=$(echo ${currentVersion} | cut -d\- -f1)
    ${basedir}/setVersion.sh ${newVersion}
else
    echo "Current version is not a snapshot, can't be closed"
    exit 1
fi
