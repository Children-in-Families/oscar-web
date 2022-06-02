#!/bin/bash -ex
echo "Testing"
make db_create_test
make rspec