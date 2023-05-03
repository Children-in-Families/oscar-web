#!/bin/bash

# Get UserID
USER_ID=${LOCAL_USER_ID:-1000}
usermod --non-unique --uid $USER_ID deployer
groupmod --non-unique --gid $USER_ID deployer

# chown $LOCAL_USER_ID:$LOCAL_USER_ID /run/nginx.pid
exec "$@"
