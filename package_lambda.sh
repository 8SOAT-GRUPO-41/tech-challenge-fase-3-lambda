#!/bin/bash
set -e

# Create a clean build directory
BUILD_DIR="lambda_build"
ZIP_FILE="lambda_function.zip"

echo "Creating clean build directory..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

echo "Installing production dependencies..."
npm install --only=prod --prefix $BUILD_DIR

echo "Copying source files..."
cp -r src $BUILD_DIR/

echo "Creating Lambda package..."
cd $BUILD_DIR
zip -r "../$ZIP_FILE" ./* > /dev/null
cd ..

echo "Package created: $ZIP_FILE"
