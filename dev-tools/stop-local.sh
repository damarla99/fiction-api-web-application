#!/bin/bash

##############################################################################
# Stop Local Development Environment
# For: Application Developers
##############################################################################

echo "🛑 Stopping local development environment..."
echo ""

docker-compose down

echo ""
echo "✅ All services stopped"
echo ""
echo "💡 Data is preserved in Docker volumes"
echo "   Run './dev-tools/start-local.sh' to start again"
echo ""

