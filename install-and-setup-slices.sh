#!/bin/bash

# ------------- Parameters -------------
PROJECT_ID="thesis-senne2026"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"   # replace by the actual path of your public SSH key
# --------------------------------------

# install slices
echo "Installing Slices CLI"
pip install slices-cli --extra-index-url=https://doc.slices-ri.eu/pypi/

# authenticate with your UGent account via browser
echo "Authenticating via browser"
slices auth login
echo "Successfully authenticated"

# select your project
echo "Using project: $PROJECT_ID"
slices project use "$PROJECT_ID"

# register your public ssh key
echo "Registering key: $SSH_KEY_PATH"
slices pubkey register "$SSH_KEY_PATH"
