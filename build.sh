#!/bin/bash
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Enabling Flutter Web..."
flutter config --enable-web

echo "Building Flutter Web application..."
if [ -z "$BASE_URL" ]; then
  flutter build web --release
else
  flutter build web --release --dart-define=BASE_URL=$BASE_URL
fi

echo "Preparing Vercel output directory..."
mkdir -p public
cp -r build/web/* public/
echo "Done!"
