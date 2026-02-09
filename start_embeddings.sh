#!/bin/bash

# Start MLX OpenAI Server for Embeddings Model
# Usage: ./start_embeddings.sh [model]
# Example: ./start_embeddings.sh mlx-community/qwen3-embedding-0.6b-8bit

MODEL="${1:-mlx-community/Qwen3-Embedding-4B-4bit-DWQ}"
HOST="127.0.0.1"
PORT="8000"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/embeddings_server.log"
PID_FILE="embeddings_server.pid"

mkdir -p "$LOG_DIR"

if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE")
  if ps -p "$OLD_PID" > /dev/null 2>&1; then
    echo "Server is already running with PID: $OLD_PID"
    echo "To stop it, run: kill $OLD_PID"
    exit 1
  else
    echo "Removing stale PID file..."
    rm "$PID_FILE"
  fi
fi

echo "Starting MLX OpenAI Server for embeddings..."
echo "Model: $MODEL"
echo "Logs will be written to: $LOG_FILE"

nohup uv run mlx-openai-server launch \
  --model-type embeddings \
  --model-path "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --max-concurrency 4 \
  --queue-timeout 300 \
  --queue-size 100 \
  --log-file "$LOG_FILE" \
  > /dev/null 2>&1 &

PID=$!
echo $PID > "$PID_FILE"

echo "Server started with PID: $PID"
echo "Server listening on: http://$HOST:$PORT"
echo "PID saved to: $PID_FILE"
echo "To stop the server, run: kill $PID (or kill \$(cat $PID_FILE))"
echo "To view logs, run: tail -f $LOG_FILE"
