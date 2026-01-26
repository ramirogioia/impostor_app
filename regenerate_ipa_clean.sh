#!/bin/bash
set -e

echo "🧹 Limpiando build anterior..."
cd "$(dirname "$0")"
flutter clean
rm -rf build/ipa build/Runner.xcarchive ios/Pods ios/.symlinks

echo ""
echo "📦 Regenerando iconos..."
python3 fix_ios_icons.py

echo ""
echo "🔨 Generando nuevo IPA..."
cd ios
./build_archive.sh

echo ""
echo "✅ IPA regenerado con iconos actualizados"
