#!/usr/bin/env bash
# Start OpenClaw Gateway and ngrok tunnel for LINE webhook
set -e

NGROK="/c/Users/tcwan/AppData/Local/Microsoft/WinGet/Packages/Ngrok.Ngrok_Microsoft.Winget.Source_8wekyb3d8bbwe/ngrok.exe"
GATEWAY_PORT=18789

echo "Starting OpenClaw Gateway on port $GATEWAY_PORT..."
npx openclaw gateway --port "$GATEWAY_PORT" --verbose &
GATEWAY_PID=$!

# Wait for gateway to be ready
sleep 3

echo "Starting ngrok tunnel..."
"$NGROK" http "$GATEWAY_PORT" &
NGROK_PID=$!

sleep 2
echo ""
echo "================================================"
echo "  Gateway:  ws://127.0.0.1:$GATEWAY_PORT"
echo "  WebChat:  http://127.0.0.1:$GATEWAY_PORT/__openclaw__/canvas/"
echo "  ngrok:    http://127.0.0.1:4040 (inspect traffic)"
echo "================================================"
echo ""
echo "Set your LINE Webhook URL to: <ngrok-url>/line"
echo "Press Ctrl+C to stop both services."

# Trap Ctrl+C to kill both processes
trap 'echo "Stopping..."; kill $GATEWAY_PID $NGROK_PID 2>/dev/null; exit 0' INT TERM

wait
