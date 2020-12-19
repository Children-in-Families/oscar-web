#!/usr/bin/env bash

basedir=$(dirname $0)
currentVersion=$(${basedir}/getVersion.sh)
versionMinor=$(echo ${currentVersion} | rev | cut -d\. -f1 | rev)
versionMajor=${currentVersion: 0: -${#versionMinor} }
newVersion=${versionMajor}$((versionMinor+1))
${basedir}/setVersion.sh ${newVersion}
