#!/usr/bin/env bash
set -euxo pipefail

# Check health endpoint
curl -sf http://localhost/health

# Ensure index.html exists
test -f /var/www/html/index.html
