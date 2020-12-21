#!/usr/bin/env bash
basedir=$(dirname $0)
version=$(${basedir}/version/getVersion.sh)
instance_name=$(cat ${basedir}/instance_name)
awsName=$(${basedir}/version/getawsImageName.sh)

echo Building version ${version} of ${instance_name}

docker build --tag ${instance_name}:${version} ${basedir}/..
docker tag ${instance_name}:${version} ${awsName}
echo "$basedir"
