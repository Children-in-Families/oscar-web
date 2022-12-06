#!/bin/bash -ex
echo "Testing"
make db_create_test
make db_migrate
make rspec