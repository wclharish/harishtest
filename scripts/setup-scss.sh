#!/bin/bash

# Script to set up SCSS structure in the scss directory (not uploaded to Shopify)
# and compile to assets/theme.css (which will be uploaded to Shopify)

echo "Setting up SCSS structure..."

# Create SCSS directory structure (source files - not uploaded to Shopify)
mkdir -p scss
mkdir -p scss/components
mkdir -p scss/layout
mkdir -p scss/utils

# Create main SCSS file
cat > scss/theme.scss << EOL
/*
* Shopify Theme SCSS Main File
*/

@use "utils" as *;

// Layout
@use "layout/header";
@use "layout/footer";
@use "layout/grid";

// Components
@use "components/buttons";
@use "components/forms";
@use "components/navigation";
EOL

# Create utility files
cat > scss/utils/_variables.scss << EOL
// Colors
\$color-primary: #000000;
\$color-secondary: #333333;
\$color-accent: #ff0000;
\$color-background: #ffffff;

// Typography
\$font-body: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
\$font-heading: \$font-body;
EOL

cat > scss/utils/_mixins.scss << EOL
@mixin flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

@mixin responsive-image {
  max-width: 100%;
  height: auto;
}

@mixin visually-hidden {
  position: absolute;
  overflow: hidden;
  clip: rect(0 0 0 0);
  height: 1px;
  width: 1px;
  margin: -1px;
  padding: 0;
  border: 0;
}
EOL

# Create empty layout files
cat > scss/utils/_index.scss << EOL
@forward "variables";
@forward "mixins";
EOL

cat > scss/layout/_header.scss << EOL
@use "../utils" as *;

// Header styles
EOL

cat > scss/layout/_footer.scss << EOL
@use "../utils" as *;

// Footer styles
EOL

cat > scss/layout/_grid.scss << EOL
@use "../utils" as *;

// Grid system styles
EOL

# Create empty component files
cat > scss/components/_buttons.scss << EOL
@use "../utils" as *;

// Button styles
EOL

cat > scss/components/_forms.scss << EOL
@use "../utils" as *;

// Form styles
EOL

cat > scss/components/_navigation.scss << EOL
@use "../utils" as *;

// Navigation styles
EOL

# Ensure the assets directory exists
mkdir -p assets

# Create or update .shopifyignore file to exclude scss directory
if [ -f ".shopifyignore" ]; then
  # Check if scss/ is already in .shopifyignore
  if ! grep -q "scss/" .shopifyignore; then
    echo "scss/" >> .shopifyignore
    echo "Added scss/ to .shopifyignore file"
  fi
else
  echo "scss/" > .shopifyignore
  echo "Created .shopifyignore file with scss/ directory excluded"
fi

# Check if theme.liquid exists and contains theme.css reference
if [ -f "layout/theme.liquid" ]; then
  if ! grep -q "theme.css.*asset_url.*stylesheet_tag" layout/theme.liquid; then
    echo "Warning: theme.css may not be properly included in your theme.liquid file."
    echo "Please ensure it has this line somewhere in the <head> section:"
    echo "{{ 'theme.css' | asset_url | stylesheet_tag }}"
  else
    echo "Confirmed theme.css is properly included in theme.liquid"
  fi
else
  echo "Warning: layout/theme.liquid file not found."
  echo "Please ensure to include theme.css in your main layout file:"
  echo "{{ 'theme.css' | asset_url | stylesheet_tag }}"
fi

# Create package.json with sass build/watch scripts when missing
if [ ! -f "package.json" ]; then
  cat > package.json << 'EOL'
{
  "name": "shopify-theme",
  "private": true,
  "scripts": {
    "build": "sass --style=compressed --no-source-map scss/theme.scss:assets/theme.css",
    "watch": "sass --watch --style=compressed --no-source-map scss/theme.scss:assets/theme.css"
  }
}
EOL
  echo "Created package.json with build and watch scripts"
fi

# Exclude node_modules from Shopify uploads
if [ -f ".shopifyignore" ]; then
  if ! grep -q "node_modules/" .shopifyignore; then
    echo "node_modules/" >> .shopifyignore
    echo "Added node_modules/ to .shopifyignore file"
  fi
fi

# Compile SCSS to CSS
if command -v sass &> /dev/null; then
  echo "Compiling SCSS to CSS..."
  sass --style=compressed --no-source-map scss/theme.scss:assets/theme.css
else
  echo "Warning: sass is not installed. Please run 'npm install' to install dependencies."
  echo "Then run 'npm run build' to compile SCSS to CSS."
fi

echo "SCSS setup complete!"
echo "Source SCSS files are in the scss/ directory (not uploaded to Shopify)"
echo "Compiled CSS is in assets/theme.css (will be uploaded to Shopify)"
echo "Run 'npm run watch' to automatically compile SCSS to CSS when files change"