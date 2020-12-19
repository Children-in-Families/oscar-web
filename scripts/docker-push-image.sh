#!/usr/bin/env bash

basedir=$(dirname $0)
awsName=$(${basedir}/version/getawsImageName.sh)

echo Pushing ${awsName}
docker push ${awsName}

