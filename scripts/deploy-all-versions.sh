#!/bin/bash

# Configuration
VERSIONS=("3.1.6" "3.2.3" "3.2.4" "3.2.5" "3.2.6")

# Iterate through each version
for VERSION in "${VERSIONS[@]}"; do
  echo "--- Processing version $VERSION ---"

  # Remove periods from version string for the directory path
  VERSION_PATH=$(echo $VERSION | sed 's/\.//g')

  echo "Updating package.json to version $VERSION with path $VERSION_PATH..."

  # Update package.json using node -e (more robust than sed for JSON)
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.dependencies['@lightningjs/renderer'] = 'npm:@lightningtv/renderer@' + '$VERSION';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  "

  # Install the specific version
  echo "Installing dependency..."
  pnpm install

  # Build for the specific version path
  echo "Building for path $VERSION_PATH..."
  node scripts/build-github.js --path "$VERSION_PATH"

  echo "--- Finished building version $VERSION ---"
  echo ""
done

echo "Starting deployment of all built versions..."
# Deploy the accumulated dist folder to GitHub Pages
npm run deploy

echo "All versions deployed successfully."
