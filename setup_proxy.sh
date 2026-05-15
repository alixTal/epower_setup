#!/bin/bash

set -e

PROJECT_DIR="/root/epower_lab"
SERVICE_NAME="worker.service"

REPO_URL="${REPO_URL}"


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

echo "=== Set Permission for proxy binary ==="
chmod +x roxana

echo "=== Creating systemd service ==="

cat > worker.service <<EOF
[Unit]
Description=Epower Lab Worker
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/epower_lab

ExecStartPre=/usr/bin/git pull
ExecStart=/root/epower_lab/roxana

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
