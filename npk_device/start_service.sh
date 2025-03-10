#!/bin/bash
echo "Starting FastAPI server..."
cd ~/api  # Change to your FastAPI directory
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 &  # Run in background

sleep 5  # Wait for API to start

echo "Starting Flutter app..."
flutter-pi --release /home/pi/app
