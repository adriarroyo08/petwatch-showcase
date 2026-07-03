#!/bin/bash
# Updates PetWatch showcase APKs from the latest GitHub release.
# Called by n8n webhook or manually.

set -euo pipefail

DOWNLOADS_DIR="/home/ubuntu/petwatch-showcase/downloads"
REPO_DIR="/home/ubuntu/PetWatch1"

cd "$REPO_DIR"

# Get latest release tag
TAG=$(gh release view --json tagName -q '.tagName' 2>/dev/null)
if [ -z "$TAG" ]; then
    echo "ERROR: No releases found"
    exit 1
fi

MOBILE_APK="PokemonPet-Mobile-${TAG}.apk"
WEAROS_APK="PokemonPet-WearOS-${TAG}.apk"

# Check if already up to date
CURRENT=$(readlink "$DOWNLOADS_DIR/PokemonPet-Mobile-latest.apk" 2>/dev/null || echo "")
if [ "$CURRENT" = "$MOBILE_APK" ]; then
    echo "Already up to date: $TAG"
    exit 0
fi

echo "Updating APKs to $TAG..."

# Download new APKs
gh release download "$TAG" -p "*.apk" -D "$DOWNLOADS_DIR" --clobber

# Update symlinks
ln -sf "$MOBILE_APK" "$DOWNLOADS_DIR/PokemonPet-Mobile-latest.apk"
ln -sf "$WEAROS_APK" "$DOWNLOADS_DIR/PokemonPet-WearOS-latest.apk"

# Clean up old APKs (keep only current release)
find "$DOWNLOADS_DIR" -name "PokemonPet-*.apk" -not -name "*${TAG}*" -not -name "*-latest.apk" -delete

echo "Updated to $TAG"
echo "  Mobile: $(ls -lh "$DOWNLOADS_DIR/$MOBILE_APK" | awk '{print $5}')"
echo "  WearOS: $(ls -lh "$DOWNLOADS_DIR/$WEAROS_APK" | awk '{print $5}')"
