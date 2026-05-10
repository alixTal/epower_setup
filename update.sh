#!/bin/bash

set -e

PROJECT_DIR="/root/epower_lab"
SERVICE_NAME="worker.service"

echo "=== Stopping service ==="
systemctl stop $SERVICE_NAME

echo "=== Updating repository ==="
cd "$PROJECT_DIR"

git pull

echo "=== Starting service ==="
systemctl start $SERVICE_NAME

echo "=== Update completed successfully ==="

systemctl status $SERVICE_NAME --no-pager
