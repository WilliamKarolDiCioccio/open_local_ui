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

# Define base path for build output
buildOutputBasePath="./app/build/linux/x64"

# Map configurations to their respective output paths
declare -A buildPaths
buildPaths["debug"]="$buildOutputBasePath/debug/bundle"
buildPaths["release"]="$buildOutputBasePath/release/bundle"

# Check if the provided configuration is valid
if [[ -z "${buildPaths[$config]}" ]]; then
    error_exit "Invalid configuration. Please use 'debug' or 'release'."
fi

# Define the Python script and executable names
pythonScriptName="main.py"
executableName="server"

# Store the current workspace path and define the Python project path
workspacePath=$(pwd)
pythonProjectPath="./server"

# Change directory to the Python project path
cd $pythonProjectPath

# Check if the virtual environment exists, and create it if it doesn't
if [ ! -d "./.venv" ]; then
    python3 -m venv "./.venv"
fi

# Activate the virtual environment
source "./.venv/bin/activate"

# Install requirements in the virtual environment
pip install -r requirements.txt

# Use PyInstaller to package the Python script into an executable
pyinstaller --onefile --name $executableName "./src/$pythonScriptName"

# Change directory back to the original workspace path
cd $workspacePath

# Define the output directory of PyInstaller
pyinstallerOutputDir="$pythonProjectPath/dist"

# Define the target directory based on the configuration
targetDir=${buildPaths[$config]}

# Create the target directory if it doesn't exist
mkdir -p $targetDir

# Move the generated executable to the target directory
mv "$pyinstallerOutputDir/$executableName" "$targetDir/$executableName"

# Clean up: remove the virtual environment and temporary build files
rm -rf "$pythonProjectPath/build"
rm -rf "$pythonProjectPath/dist"
rm -f "$pythonProjectPath/*.spec"

# Output a message indicating that the build and packaging process is complete
echo "Build and packaging complete. The executable has been moved to $targetDir"
