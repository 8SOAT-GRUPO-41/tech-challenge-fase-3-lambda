#!/bin/bash
set -e

# Variables
BUILD_DIR="lambda_build"
ZIP_FILE="lambda_function.zip"
ROOT_DIR="$(pwd)"

echo "Creating clean build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Installing production dependencies using Yarn..."
cp package.json yarn.lock "$BUILD_DIR/"
cd "$BUILD_DIR"
yarn install --production --silent
cd "$ROOT_DIR"

echo "Copying source files..."
cp -r src "$BUILD_DIR/"

echo "Creating Lambda package..."
cd "$BUILD_DIR"
zip -r "../$ZIP_FILE" ./* > /dev/null
cd "$ROOT_DIR"

echo "Cleaning up unnecessary files..."
rm -f "$BUILD_DIR/package.json" "$BUILD_DIR/yarn.lock"

echo "Package created: $ZIP_FILE"
