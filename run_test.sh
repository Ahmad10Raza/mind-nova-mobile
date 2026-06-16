#!/bin/bash
cd /home/ahmad10raza/Documents/Major\ Projects/MindNova/mind_nova_mobile
flutter run -d linux > flutter_out.txt 2>&1 &
FLUTTER_PID=$!
echo "Running flutter app (PID $FLUTTER_PID)..."
sleep 15
kill $FLUTTER_PID
