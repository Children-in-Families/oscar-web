#!/usr/bin/env bash

getBranchName()
{
    echo $(git rev-parse --abbrev-ref HEAD)
}

getMergedBranches()
{
    echo $(git branch --merged)
}

if [ "$(getBranchName)" != "staging" ]; then
    if [[ $(getMergedBranches) == *"staging"* ]]; then
        echo "Don't create branches from the staging branch!"
        exit 1
    fi
fi