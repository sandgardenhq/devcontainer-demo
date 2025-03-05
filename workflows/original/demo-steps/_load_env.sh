#!/bin/bash

set -e

# This loads the necessary env vars based on whether the demo
# is run in docker or lambda mode

function load_env() {
  if [ -z "$DEMO_TYPE" ]; then
    echo "Error: DEMO_TYPE environment variable not set. Must be either 'docker' or 'awslambda'"
    exit 1
  fi

  # If DEMO_TYPE is "docker", use docker compose instead of lambda
  if [ "$DEMO_TYPE" == "docker" ]; then
    export STEP_TYPE="docker"
    export STEP_OPTS="--network sandgarden_demo_network"

    export DB_HOST="postgres"
    export DB_PORT="5432"
    export DB_NAME="tickets"
    export DB_USER="tickets"
    export DB_PASS="devpassword"
  elif [[ "${DEMO_TYPE}" == "awslambda" || "${DEMO_TYPE}" == "awsLambda" ]]; then
    export STEP_TYPE="awsLambda"
    # Read values from outputs.json
    export OUTPUTS_FILE="${SCRIPT_DIR}/../director_deploy/outputs.json"

    # Check if outputs.json exists
    if [ ! -f "$OUTPUTS_FILE" ]; then
      echo "Error: outputs.json not found. "
      exit 1
    fi

    AWS_ROLE=$(jq -r '.lambda_role_arn.value' $OUTPUTS_FILE)
    export AWS_ROLE
    DB_HOST=$(jq -r '.db_host.value' $OUTPUTS_FILE)
    export DB_HOST
    DB_PORT=$(jq -r '.db_port.value' $OUTPUTS_FILE)
    export DB_PORT
    DB_NAME=$(jq -r '.db_name.value' $OUTPUTS_FILE)
    export DB_NAME
    DB_USER=$(jq -r '.db_username.value' $OUTPUTS_FILE)
    export DB_USER
    DB_PASS=$(jq -r '.db_password.value' $OUTPUTS_FILE)

    export STEP_OPTS="--role $AWS_ROLE --timeoutSeconds 120"
  else
    echo "Error: Invalid DEMO_TYPE: $DEMO_TYPE"
    echo "Must be either 'docker' or 'awslambda'"
    exit 1
  fi
}

function green() {
  echo -e "\033[0;32m$1\033[0m"
}
