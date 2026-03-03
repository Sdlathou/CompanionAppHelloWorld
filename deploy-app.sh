#!/bin/bash
# deploy-app.sh — run on the Ubuntu 24.04 VM (as the ubuntu user with sudo)
# after SSH access is obtained via the provisioning flow.
#
# What it does:
#   1. Installs git (if not present) so the repo can be cloned.
#   2. Clones (or updates) this repository to ~/app.
#   3. Registers a systemd service that starts the Python 3 backend on port 8080.
#   4. Opens port 8080 in ufw.
#
# Usage (from your local machine):
#   ssh ubuntu@<VM_IP> 'bash -s' < deploy-app.sh
# Or copy it to the VM first and run it there directly.

set -euo pipefail

REPO_URL="https://github.com/Sdlathou/CompanionAppHelloWorld.git"
APP_DIR="$HOME/CompanionAppHelloWorld"
SERVICE_NAME="helloworld"
PORT=8080

# ── 1. Install git ──────────────────────────────────────────────────────────
echo "==> Ensuring git is installed..."
sudo apt-get update -qq
sudo apt-get install -y -qq git

# ── 2. Clone or update the repository ──────────────────────────────────────
if [ -d "$APP_DIR/.git" ]; then
  echo "==> Updating existing repo at $APP_DIR..."
  git -C "$APP_DIR" pull --ff-only
else
  echo "==> Cloning repo to $APP_DIR..."
  git clone "$REPO_URL" "$APP_DIR"
fi

# ── 3. Install systemd service ──────────────────────────────────────────────
echo "==> Writing systemd unit /etc/systemd/system/${SERVICE_NAME}.service..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=Hello World backend (Python 3)
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/python3 ${APP_DIR}/app/backend/server.py
Restart=on-failure
Environment=PORT=${PORT}

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ${SERVICE_NAME}.service
echo "==> Service '${SERVICE_NAME}' started."

# ── 4. Open firewall port ──────────────────────────────────────────────────
if command -v ufw &>/dev/null; then
  echo "==> Opening port ${PORT} in ufw..."
  sudo ufw allow "${PORT}/tcp" || true
fi

# ── 5. Done ────────────────────────────────────────────────────────────────
VM_IP=$(hostname -I | awk '{print $1}')
echo ""
echo "✅  Deployment complete."
echo "   Frontend : http://${VM_IP}:${PORT}/"
echo "   API      : http://${VM_IP}:${PORT}/api/hello"
