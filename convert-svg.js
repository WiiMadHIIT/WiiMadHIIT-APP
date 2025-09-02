const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

async function convertSvgToPng() {
  const svgPath = 'assets/icons/wiimadhiit-w-red.svg';
  const pngPath = 'assets/icons/app_icon.png';
  
  try {
    // Check if SVG file exists
    if (!fs.existsSync(svgPath)) {
      console.error(`❌ SVG file not found: ${svgPath}`);
      return false;
    }
    
    // Create directory if it doesn't exist
    const dir = path.dirname(pngPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    // Convert SVG to PNG
    await sharp(svgPath)
      .resize(1024, 1024)
      .png()
      .toFile(pngPath);
    
    console.log(`✅ Successfully converted ${svgPath} to ${pngPath} (1024x1024)`);
    console.log('🎉 Now you can run: flutter pub run flutter_launcher_icons');
    return true;
  } catch (error) {
    console.error(`❌ Error converting SVG: ${error.message}`);
    return false;
  }
}

convertSvgToPng();
