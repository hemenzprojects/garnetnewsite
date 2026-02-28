#!/bin/bash

###############################################################################
# Upload Code to Server
# Excludes node_modules, vendor, and build artifacts
#
# Usage: bash upload-to-server.sh
###############################################################################

SERVER="sysadmin@169.239.249.15"
REMOTE_PATH="/var/www/garnet"

echo "Uploading code to server..."
echo "Server: $SERVER"
echo "Path: $REMOTE_PATH"

rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.nuxt' \
  --exclude '.output' \
  --exclude 'dist' \
  --exclude 'vendor' \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude 'backend/storage/logs/*' \
  --exclude 'backend/.env' \
  --exclude 'frontend/.env' \
  --exclude '.env.production' \
  ./ $SERVER:$REMOTE_PATH/

echo ""
echo "✓ Upload complete!"
echo ""
echo "Next steps on server:"
echo "1. cd /var/www/garnet"
echo "2. bash deployment/update.sh"