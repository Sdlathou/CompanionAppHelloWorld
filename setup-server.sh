#!/bin/bash

# ------ Parameters ------
EXP_NAME="thesis-senne2026-exp"
SERVER_NAME="server-1"          # replace by a unique server name within the experiment
IMAGE="Ubuntu 24.04.1"          # replace if needed by another image with 'be-gent1-bi-vm1' as 'Infra ID'
                                # listed by 'slices bi diskimage list'
FLAVOR="medium"                 # replace if needed by another VM (!) flavor listed by 'slices bi flavor list'
USE_PUBLIC_IP=true              # set to 'false' if not needed
# ------------------------

# handle public IPv4 flag
IP_FLAG=""
if [ "$USE_PUBLIC_IP" = true ]; then
    IP_FLAG="--public-ipv4"
fi

# request server resource and wait until ready
echo "Provisioning server '$SERVER_NAME'..."
slices bi create $SERVER_NAME \
    --duration 89d \
    --image "$IMAGE" \
    --flavor "$FLAVOR" \
    --experiment "$EXP_NAME" \
    $IP_FLAG \
    --wait
echo "Server ready"

# retrieve login command
LOGIN_COMMAND=$(slices bi ssh $SERVER_NAME --show command --no-exec)
echo "Log in to server with: $LOGIN_COMMAND"
