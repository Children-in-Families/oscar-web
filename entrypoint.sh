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

# Setup the database
rake db:setup # perfoms db:create, db:schema:load, db:seed

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
