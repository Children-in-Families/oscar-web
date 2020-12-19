#!/usr/bin/env bash

basedir=$(dirname $0)
version=$(${basedir}/getVersion.sh)
awsData=$(cat ${basedir}/../aws.data)
instance_name=$(cat ${basedir}/../instance_name)

echo ${awsData}/${instance_name}:${version}
