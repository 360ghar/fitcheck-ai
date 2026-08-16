#!/bin/bash

# FitCheck AI - Development Server Runner
# Runs both backend (FastAPI) and frontend (Vite) servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

# PIDs for cleanup
BACKEND_PID=""
FRONTEND_PID=""

cleanup() {
    echo -e "\n${YELLOW}Shutting down servers...${NC}"

    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo -e "${BLUE}Stopping backend server (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null || true
    fi

    if [ -n "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
        echo -e "${BLUE}Stopping frontend server (PID: $FRONTEND_PID)...${NC}"
        kill "$FRONTEND_PID" 2>/dev/null || true
    fi

    echo -e "${GREEN}All servers stopped.${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   FitCheck AI - Development Server    ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Start Backend Server
echo -e "${BLUE}Starting Backend Server (FastAPI)...${NC}"
echo -e "${YELLOW}Backend URL: http://localhost:8000${NC}"
echo -e "${YELLOW}API Docs: http://localhost:8000/api/v1/docs${NC}"
echo ""

cd "$BACKEND_DIR"
if [ ! -d "$BACKEND_DIR/.venv" ]; then
    echo -e "${RED}Error: backend virtualenv not found at $BACKEND_DIR/.venv${NC}"
    echo -e "${YELLOW}Create it with:${NC}"
    echo -e "  cd $BACKEND_DIR"
    echo -e "  python3 -m venv .venv"
    echo -e "  source .venv/bin/activate"
    echo -e "  pip install -r requirements.txt"
    exit 1
fi
source "$BACKEND_DIR/.venv/bin/activate"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# Wait for the backend to become healthy (bounded retry loop instead of a
# fixed sleep: slower cold starts are tolerated, a dead process fails fast).
echo -e "${YELLOW}Waiting for backend health (http://localhost:8000/health)...${NC}"
BACKEND_READY=""
for _ in $(seq 1 30); do
    if curl -fsS http://localhost:8000/health >/dev/null 2>&1; then
        BACKEND_READY="yes"
        break
    fi
    if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo -e "${RED}Backend process exited before becoming healthy${NC}"
        exit 1
    fi
    sleep 1
done
if [ -n "$BACKEND_READY" ]; then
    echo -e "${GREEN}Backend is healthy.${NC}"
else
    echo -e "${YELLOW}Backend not healthy after 30s — continuing anyway; check logs with: tail -f $BACKEND_DIR/logs/*.log${NC}"
fi

# Start Frontend Server
echo -e "${BLUE}Starting Frontend Server (Vite)...${NC}"
echo -e "${YELLOW}Frontend URL: http://localhost:3000${NC}"
echo ""

cd "$FRONTEND_DIR"
npm run dev &
FRONTEND_PID=$!

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Both servers are running!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "  Backend:  ${YELLOW}http://localhost:8000${NC}"
echo -e "  Frontend: ${YELLOW}http://localhost:3000${NC}"
echo -e "  API Docs: ${YELLOW}http://localhost:8000/api/v1/docs${NC}"
echo ""
echo -e "${BLUE}Press Ctrl+C to stop both servers${NC}"
echo ""

# Wait for both processes
wait
