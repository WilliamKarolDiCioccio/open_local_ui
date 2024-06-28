#!/bin/bash

# Function to display an error message and exit
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Parse the configuration parameter
config="debug"
if [ $# -eq 1 ]; then
    config=$1
fi

# Define base command for build
baseBuildCommand="flutter build linux"

# Map configurations to their respective output commands
declare -A buildCommands
buildCommands["debug"]="$baseBuildCommand --debug"
buildCommands["release"]="$baseBuildCommand --release --obfuscate --split-debug-info=./build/debug_info --extra-gen-snapshot-options=--save-obfuscation-map=./build/obfuscation_map.json"

# Check if the provided configuration is valid
if [[ -z "${buildCommands[$config]}" ]]; then
    error_exit "Invalid configuration. Please use 'debug' or 'release'."
fi

# Create the necessary directory if it doesn't exist
if [ "$config" = "release" ]; then
    mkdir -p ./build/debug_info
fi

# Run the build command based on the provided configuration
eval "${buildCommands[$config]}"

# Output a message indicating that the build and packaging process is complete
echo "Build and packaging complete"
