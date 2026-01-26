#!/usr/bin/env python3
"""
Script para asegurar que todos los iconos de iOS tengan fondo negro.
Ejecutar después de flutter pub run flutter_launcher_icons si es necesario.
"""
from PIL import Image
import os
import re

source = 'assets/images/icon_square_ios.png'
icon_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/'

if not os.path.exists(source):
    print('❌ No se encontró icon_square_ios.png')
    exit(1)

source_img = Image.open(source)
if source_img.size != (1024, 1024):
    source_img = source_img.resize((1024, 1024), Image.Resampling.LANCZOS)

def get_size_from_filename(filename):
    match = re.search(r'(\d+(?:\.\d+)?)x(\d+(?:\.\d+)?)@?(\d*)x?', filename)
    if match:
        base = float(match.group(1))
        scale = int(match.group(3)) if match.group(3) else 1
        return int(base * scale)
    return None

replaced = 0
if os.path.exists(icon_dir):
    for filename in os.listdir(icon_dir):
        if filename.endswith('.png'):
            filepath = os.path.join(icon_dir, filename)
            try:
                target_size = get_size_from_filename(filename)
                if target_size:
                    target_img = source_img.resize((target_size, target_size), Image.Resampling.LANCZOS)
                else:
                    target_img = source_img.copy()
                target_img.save(filepath, 'PNG')
                replaced += 1
            except Exception as e:
                print(f'Error con {filename}: {e}')

print(f'✅ {replaced} iconos actualizados con fondo negro')
