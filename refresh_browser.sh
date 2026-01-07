#!/bin/bash
# Script to remotely refresh the Chromium browser on reTerminal

echo "Killing Chromium browser..."
ssh -i ~/.ssh/reterminal_key pi@192.168.0.3 'pkill -f "chromium-browser.*kiosk"'

sleep 2

echo "Restarting Chromium in kiosk mode..."
ssh -i ~/.ssh/reterminal_key pi@192.168.0.3 'DISPLAY=:0 chromium-browser --force-renderer-accessibility --disable-quic --enable-tcp-fast-open --enable-pinch --kiosk --touch-events=enabled http://localhost:5000 &'

echo "Browser refresh complete!"
