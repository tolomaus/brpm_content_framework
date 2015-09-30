#!/usr/bin/env bash
USAGE="publish_module_version.sh <module name>"

MODULE_NAME=$1

if [ -z "$MODULE_NAME" ]; then
    echo "Module name is not specified. Aborting."
    echo "Usage: $USAGE"
    exit 1
fi

cd $(dirname $0)/../../../$MODULE_NAME

echo ""
echo ">>> Publishing the module as a gem to rubygems.org..."
rake release
if [ -f "docker/Dockerfile" ]; then
    MODULE_VERSION=$(eval "sed -n \"s=version: \(.*\)=\1=p\" config.yml")

    cd docker

    OLD_MODULE_VERSION=$(eval "sed -n \"s=ENV VERSION \(.*\)=\1=p\" Dockerfile")
    sed -i "" s/$OLD_MODULE_VERSION/$MODULE_VERSION/ Dockerfile

    echo ""
    echo ">>> Building the docker image..."
    docker build -t bmcrlm/$MODULE_NAME:$MODULE_VERSION . || { echo 'Aborting' ; exit 1; }

    sed -i "" s/$MODULE_VERSION/$OLD_MODULE_VERSION/ Dockerfile

    echo ""
    echo ">>> Publishing the docker image to the docker hub..."
    docker push bmcrlm/$MODULE_NAME:$MODULE_VERSION || { echo 'Aborting' ; exit 1; }

    echo ""
    echo ">>> Tagging the module version as 'latest'..."
    docker tag -f bmcrlm/$MODULE_NAME:$MODULE_VERSION bmcrlm/$MODULE_NAME:latest || { echo 'Aborting' ; exit 1; }
    docker push bmcrlm/$MODULE_NAME:latest || { echo 'Aborting' ; exit 1; }
fi