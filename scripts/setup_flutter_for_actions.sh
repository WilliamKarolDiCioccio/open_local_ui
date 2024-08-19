#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
FLUTTER_VERSION="3.24.0-stable"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}.tar.xz"
FLUTTER_DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"
INSTALL_DIR="/usr/bin/flutter"

# Step 1: Download the Flutter SDK
echo "Downloading Flutter SDK..."
wget ${FLUTTER_DOWNLOAD_URL}

# Step 2: Create installation directory if it doesn't exist
if [ ! -d "/usr/bin/" ]; then
    echo "Creating /usr/bin/ directory..."
    sudo mkdir -p /usr/bin/
fi

# Step 3: Extract the Flutter SDK to the installation directory
echo "Installing Flutter SDK to ${INSTALL_DIR}..."
sudo tar -xf ${FLUTTER_TAR} -C /usr/bin/

# Step 4: Add Flutter to the PATH environment variable
echo "Adding Flutter to the PATH..."
FLUTTER_BIN_PATH="/usr/bin/flutter/bin"
echo "FLUTTER_BIN_PATH=${FLUTTER_BIN_PATH}" >> $GITHUB_ENV
echo "PATH=${FLUTTER_BIN_PATH}:$PATH" >> $GITHUB_ENV

# Step 5: Verify Flutter installation
echo "Verifying Flutter installation..."
/usr/bin/flutter/bin/flutter --version

# Step 6: Run Flutter doctor to ensure installation is complete
echo "Running Flutter doctor to finalize setup..."
/usr/bin/flutter/bin/flutter doctor

# Final Message
echo "Flutter installation completed successfully!"
