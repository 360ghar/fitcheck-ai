#!/bin/bash

# ===========================================
# CONFIGURATION - Edit these values
# ===========================================
PORT=1999
NGROK_DOMAIN="unglamourous-unregistered-milo.ngrok-free.dev"  # Set to your ngrok static domain (e.g., my-app.ngrok-free.app)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validation
if [ -z "$NGROK_DOMAIN" ]; then
    echo -e "${RED}Error: NGROK_DOMAIN is not set${NC}"
    echo "Edit this script and set NGROK_DOMAIN to your ngrok static domain"
    echo "Get one free at: https://dashboard.ngrok.com/cloud-edge/domains"
    exit 1
fi

if ! command -v ngrok &> /dev/null; then
    echo -e "${RED}Error: ngrok is not installed${NC}"
    echo "Install with: brew install ngrok"
    exit 1
fi

# Navigate to backend directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(dirname "$SCRIPT_DIR")"
cd "$BACKEND_DIR"

# Activate venv if exists
if [ -d ".venv" ]; then
    source .venv/bin/activate
    echo -e "${GREEN}Activated virtual environment${NC}"
fi

# Cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down...${NC}"
    kill $BACKEND_PID 2>/dev/null
    kill $NGROK_PID 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# Start backend
echo -e "${GREEN}Starting backend on port $PORT...${NC}"
uvicorn app.main:app --host 0.0.0.0 --port $PORT --reload &
BACKEND_PID=$!
sleep 3

if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}Failed to start backend${NC}"
    exit 1
fi

# Start ngrok
echo -e "${GREEN}Starting ngrok tunnel...${NC}"
ngrok http $PORT --domain=$NGROK_DOMAIN &
NGROK_PID=$!

echo -e "\n${GREEN}==================================${NC}"
echo -e "${GREEN}Backend: http://localhost:$PORT${NC}"
echo -e "${GREEN}Public:  https://$NGROK_DOMAIN${NC}"
echo -e "${GREEN}Docs:    https://$NGROK_DOMAIN/api/v1/docs${NC}"
echo -e "${GREEN}==================================${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}\n"

wait
