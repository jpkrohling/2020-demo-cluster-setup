#!/usr/bin/env bash

printf "\n\n######## scoring/deploy ########\n"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT=${PROJECT:-scoring}
CLUSTER_NAME=${CLUSTER_NAME:-EDGE}

oc project ${PROJECT} 2> /dev/null || oc new-project ${PROJECT}
oc adm policy add-scc-to-user anyuid -n scoring -z default

curl -fL https://github.com/skupperproject/skupper-cli/releases/download/0.1.0/skupper-cli-0.1.0-mac-amd64.tgz | tar -xzf -

SKUPPER_NAME="$(echo ${CLUSTER_NAME} | gsed 's/ /_/g')"
./skupper init --enable-router-console --router-console-auth openshift --id ${SKUPPER_NAME}
./skupper connect token.yaml

echo "Deploying Scoring Service"

oc process -f "${DIR}/scoring-server.yml" -p CLUSTER_NAME="${CLUSTER_NAME}" | oc create -f -
