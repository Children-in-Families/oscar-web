#!/bin/bash -ex

exit 0
#
# Check to make sure the script run as current user
#
GREEN="\033[0;32m"
BROWN="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

FILE_NAME=$(basename "$0")
STAGE="${FILE_NAME%.*}"
BUNDLE_VERSION="1.17.3"

BUNDLE_VERSION_CHECK=`bundle --version 2> /dev/null | grep "${BUNDLE_VERSION}"`
if [ -z "${BUNDLE_VERSION_CHECK}" ]; then
	echo
	echo -e "${RED}Ansible version ${BUNDLE_VERSION} still cannot be found in the path."
	echo -e "Please verify with 'ansible --version' command and fix it manually first.${NC}"
	exit
fi

ansible-playbook config/ansible/playbook.yml -t deploy -vv \
    -l ${STAGE} \
    -e stage=${STAGE} \
    -e version=${DEPLOY_ID} \
    -e workspace=${WORKSPACE}
