#!/bin/bash

function green() {
  echo -e "\033[0;32m$1\033[0m"
}

set -e

SGCLI="sand"

export STEP_TYPE="docker"
export STEP_OPTS="--network sandgarden_demo_network"

export DB_HOST="postgres"
export DB_PORT="5432"
export DB_NAME="tickets"
export DB_USER="tickets"
export DB_PASS="devpassword"

green "Checking Director access..."

$SGCLI health || {
    green "Director not available, halting setup"
    green "SAND_BACKEND_URL set to: $SAND_BACKEND_URL"
    exit 1
}

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY is not set. Please set it and try again."
  exit 1
fi

export COMMON_OPTS="--connector tickets-postgres --tag=latest --sync=true $STEP_OPTS"
export SAND_FRONTEND=noninteractive

green "Configuring connectors..."

green "Creating connector tickets-postgres"
$SGCLI connectors upsert postgres \
  --name tickets-postgres \
  --database "$DB_NAME" \
  --username "$DB_USER" \
  --password "$DB_PASS" \
  --hostname "$DB_HOST" \
  --port "$DB_PORT"

green "Creating connector tickets-openai"
$SGCLI connectors upsert openai \
  --name tickets-openai \
  --api-key "$OPENAI_API_KEY"

green "Hydrating ${DB_HOST} with tickets..."

# Create a zip with two files: hydrate.py and schema.sql
rm -f hydrate.zip
zip -j hydrate.zip ../workflows/original/demo-steps/hydrate.py ../workflows/original/demo-steps/schema.sql

$SGCLI steps push $STEP_TYPE \
  --name tickets_hydrate \
  --entrypoint hydrate.handler \
  --file ./hydrate.zip \
  $COMMON_OPTS

rm -f hydrate.zip

$SGCLI steps push $STEP_TYPE \
  --name scan_tickets \
  --entrypoint scan_tickets.handler \
  --file ../workflows/original/demo-steps/scan_tickets.py \
  $COMMON_OPTS

$SGCLI steps push $STEP_TYPE \
  --name save_results \
  --entrypoint save_results.handler \
  --file ../workflows/original/demo-steps/save_results.py \
  $COMMON_OPTS

# tagging now happens separately
# $SGCLI steps tag --step save_results:1 --tag latest
# $SGCLI steps tag --step scan_tickets:1 --tag latest
# $SGCLI steps tag --step tickets_hydrate:1 --tag latest

$SGCLI runs start --step tickets_hydrate:latest --json
$SGCLI prompts create --name escalate --content escalate-prompt.txt
