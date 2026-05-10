#!/bin/bash

set -e

PROJECT_DIR="/root/epower_lab"
SERVICE_NAME="worker.service"

echo "=== Initial Setup ==="

# Inputs
read -p "Enter REPO_URL: " REPO_URL
read -p "Enter SERVER_NUMBER: " SERVER_NUMBER

echo "=== Updating packages ==="
apt update

echo "=== Installing required packages ==="
apt install -y git python3 python3-pip python3.12-venv

echo "=== Cloning repository ==="
if [ ! -d "$PROJECT_DIR" ]; then
    git clone --depth=1 "$REPO_URL" "$PROJECT_DIR"
else
    echo "Repo already exists, pulling latest..."
    cd "$PROJECT_DIR"
    git pull
    cd -
fi

cd "$PROJECT_DIR"

echo "=== Creating Python virtual environment ==="
python3 -m venv .venv

echo "=== Activating virtual environment ==="
source .venv/bin/activate

echo "=== Installing Python requirements ==="
pip3 install --upgrade pip
pip3 install -r requirements.txt

echo "=== Creating systemd service ==="

cat > worker.service <<EOF
[Unit]
Description=Epower Lab Worker
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/epower_lab
Environment="SERVER_NUMBER=$SERVER_NUMBER"

ExecStartPre=/usr/bin/git pull
ExecStart=/root/epower_lab/.venv/bin/python /root/epower_lab/worker_run.py

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "=== Installing systemd service ==="
mv worker.service /etc/systemd/system/worker.service

echo "=== Reloading systemd ==="
systemctl daemon-reload

echo "=== Enabling service ==="
systemctl enable worker.service

echo "=== Starting service ==="
systemctl start worker.service

echo "=== Setup completed ==="
systemctl status worker.service --no-pager
