#!/bin/bash -ex

exit 0
FILE_NAME=$(basename "$0")
STAGE="${FILE_NAME%.*}"

ansible-playbook config/ansible/playbook.yml -t deploy -vv \
    -l ${STAGE} \
    -e stage=${STAGE} \
    -e version=${DEPLOY_ID} \
    -e workspace=${WORKSPACE}
