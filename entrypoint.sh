#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

echo "Waiting PostgreSQL to start on 5432..."

while ! pg_isready -h db; do
  sleep 0.5
  echo "Database not ready, please wait!"
done

echo "PostgreSQL started. Setting up databases..."

# Create the development database
rake db:setup
# Import development data
echo "Preparing to import dev data. Please wait..."
rake import:dev_env_data

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
