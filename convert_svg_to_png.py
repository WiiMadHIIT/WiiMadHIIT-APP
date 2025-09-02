#!/usr/bin/env python3
"""
SVG to PNG converter for Flutter app icons
Requires: pip install cairosvg pillow
"""

import os
import sys
from cairosvg import svg2png
from PIL import Image
import io

def convert_svg_to_png(svg_path, png_path, size=1024):
    """Convert SVG to PNG with specified size"""
    try:
        # Read SVG file
        with open(svg_path, 'rb') as svg_file:
            svg_data = svg_file.read()
        
        # Convert SVG to PNG
        png_data = svg2png(bytestring=svg_data, output_width=size, output_height=size)
        
        # Save PNG file
        with open(png_path, 'wb') as png_file:
            png_file.write(png_data)
        
        print(f"✅ Successfully converted {svg_path} to {png_path} ({size}x{size})")
        return True
    except Exception as e:
        print(f"❌ Error converting {svg_path}: {e}")
        return False

def main():
    # Paths
    svg_file = "assets/icons/wiimadhiit-w-red.svg"
    png_file = "assets/icons/app_icon.png"
    
    # Check if SVG file exists
    if not os.path.exists(svg_file):
        print(f"❌ SVG file not found: {svg_file}")
        return False
    
    # Create assets/icons directory if it doesn't exist
    os.makedirs(os.path.dirname(png_file), exist_ok=True)
    
    # Convert SVG to PNG
    success = convert_svg_to_png(svg_file, png_file, 1024)
    
    if success:
        print("🎉 SVG to PNG conversion completed!")
        print("Now you can run: flutter pub run flutter_launcher_icons")
    else:
        print("💥 Conversion failed!")
    
    return success

if __name__ == "__main__":
    main()
