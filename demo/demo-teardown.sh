#!/bin/bash

# This should be run when you are done with the example
# It will destroy the resources created by the setup script
# And return you to a totally empty state

# TODO: Reduce this back to all in one namespace
sand functions delete --name="tickets_%" --force
sand functions delete --name="escalate_checker%" --force
sand functions delete --name="scan_tickets%" --force
sand functions delete --name="save_results%" --force
sand workflows delete --name="backfill%" --force

sand connectors delete --name="tickets-%" --force
sand prompts delete --name="escalate%" --force