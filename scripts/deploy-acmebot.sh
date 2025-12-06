#!/bin/bash

# Deploy KeyVault ACME Bot Function App
# Usage: ./deploy-acmebot.sh [function-app-name] [resource-group]

set -e

FUNCTION_APP_NAME="${1:-func-datorra-uks-prod-ssl-03}"
RESOURCE_GROUP="${2:-rg-datorra-ssl-uks-prod}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Initialize submodules
git submodule update --init --recursive

# Build and publish
cd KeyVault.Acmebot
dotnet publish --configuration Release --output ./publish

# Create zip package
cd publish
zip -r ../functionapp.zip . > /dev/null
cd ..

# Deploy using Azure CLI (bypasses SCM IP restrictions)
az functionapp deployment source config-zip \
  --resource-group "$RESOURCE_GROUP" \
  --name "$FUNCTION_APP_NAME" \
  --src functionapp.zip

# Cleanup
rm -f functionapp.zip
rm -rf publish

