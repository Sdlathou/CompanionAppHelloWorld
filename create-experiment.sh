#!/bin/bash

# ------ Parameters ------
EXP_NAME="thesis-senne2026-exp"
# ------------------------

# ensure script is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be sourced. Use: source $0"
    exit 1
fi

# create experiment
echo "Creating experiment: $EXP_NAME"
slices experiment create "$EXP_NAME"

# share experiment with all project members (including your promotors)
slices experiment member add "$EXP_NAME" --all-project-members

# set environment variables for all 'slices bi' commands
export SLICES_BI_SITE_ID="be-gent1-bi-vm1"
export SLICES_EXPERIMENT="$EXP_NAME"
