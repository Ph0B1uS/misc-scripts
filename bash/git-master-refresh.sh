#!/bin/bash

gitPath=$(which git)
if [ -z $gitPath ]; then
    echo "Error: git not found in path, exiting!"
    exit 1
fi
if [ ! -d $(pwd)/.git ]; then
    echo "Error: this directory is not a git repository but thanks for playing"
    exit 2
fi 
currentBranch=$($gitPath branch --show-current)
if [ -z $currentBranch ];then
    echo "Error: could not find your current branch, are you sure you are in a repo and not in detached head state?"
    exit 3
fi
$gitPath checkout master && $gitPath pull && $gitPath checkout $currentBranch
