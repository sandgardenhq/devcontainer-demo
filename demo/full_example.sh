#!/bin/bash
# This script demonstrates the complete demo without stopping
# It can be run repeatedly over and over again without any issues
#
# You must have run `./setup.sh` once successfully before running this script

set -e

green() {
  echo ""
  echo "----------------------------------------"
  echo -e "\033[32m$1\033[0m"
}

export STEP_TYPE="docker"
export STEP_OPTS="--network sandgarden_demo_network"

export ESCALATE_OPTS="--name escalate_checker --connector tickets-postgres --connector tickets-openai $STEP_OPTS"

export SAND_FRONTEND=noninteractive

green "Checking Sandgarden is available?"
sand health

green "Take a look at our initial database"
./psql.sh "UPDATE tickets SET needs_escalation=NULL"
./psql.sh "SELECT id,subject,needs_escalation FROM tickets"


green "Pushing first version of escalate_checker"
sand steps push $STEP_TYPE --entrypoint escalate_checker1.handler --file ../workflow/demo-steps/escalate_checker1.py $ESCALATE_OPTS
sand steps tag --step escalate_checker:1 --tag latest
green "Running first version of escalate_checker"
sand runs start --step=escalate_checker:latest --input='{"ticket_id": 1}'

# Composite
green "Pushing workflow: backfill"
sand workflows push --name backfill --stages=../workflow/demo-steps/backfill1.json
sand workflows tag --workflow backfill:1 --tag latest

green "Running backfill"
sand runs start --workflow=backfill:latest

green "Take a look at the results"
./psql.sh "SELECT id,subject,CASE WHEN needs_escalation THEN 'True' ELSE 'False' END AS needs_escalation FROM tickets"

green "Running test cases with first version of escalate_checker"
sand batches start --step escalate_checker:1 --in=../workflow/demo-steps/test_escalations1.jsonl --follow
FIRST_BATCH_ID=$(sand runs list --batches --json | jq -r '.runs[0].id')
sand batches get $FIRST_BATCH_ID

green "Pushing second version of escalate_checker"
sand steps push $STEP_TYPE --entrypoint escalate_checker2.handler --file ../workflow/demo-steps/escalate_checker2.py $ESCALATE_OPTS

green "Running test cases with second version of escalate_checker"
sand batches start --step escalate_checker:2 --in=../workflow/demo-steps/test_escalations2.jsonl --follow
SECOND_BATCH_ID=$(sand runs list --batches --json | jq -r '.runs[0].id')

green "Comparing results"
sand batches compare $FIRST_BATCH_ID $SECOND_BATCH_ID

green "Tagging second version as latest"
sand steps tag --step escalate_checker:2 --tag latest

green "Running backfill again to use new latest version"
sand runs start --workflow=backfill:latest

green "Take a look at the final results"
./psql.sh "SELECT id,subject,CASE WHEN needs_escalation THEN 'True' ELSE 'False' END AS needs_escalation FROM tickets"
