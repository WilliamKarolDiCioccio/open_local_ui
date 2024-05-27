param(
    [string]$config = "debug"
)

# Define base path for build output
$buildOutputBasePath = ".\app\build\windows\x64\runner"

# Map configurations to their respective output paths
$buildPaths = @{
    "debug"  = "$buildOutputBasePath\Debug"
    "release"= "$buildOutputBasePath\Release"
}

# Check if the provided configuration is valid
if (-not $buildPaths.ContainsKey($config)) {
    Write-Error "Invalid configuration. Please use 'debug' or 'release'."
    exit 1
}

# Define the Python script and executable names
$pythonScriptName = "server.py"
$executableName = "server.exe"

# Store the current workspace path and define the Python project path
$workspacePath = (Get-Location).Path
$pythonProjectPath = ".\server"

# Change directory to the Python project path
Set-Location -Path $pythonProjectPath

# Create a virtual environment for Python
python -m venv ".\venv"

# Activate the virtual environment
& ".\venv\Scripts\Activate.ps1"

# Install PyInstaller in the virtual environment
pip install pyinstaller

# Use PyInstaller to package the Python script into an executable
pyinstaller --onedir ".\src\$pythonScriptName"

# Change directory back to the original workspace path
Set-Location -Path $workspacePath

# Define the output directory of PyInstaller
$pyinstallerOutputDir = "$pythonProjectPath\dist"

# Define the target directory based on the configuration
$targetDir = $buildPaths[$config]

# Create the target directory if it doesn't exist
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

# Move the generated executable to the target directory
Move-Item -Path "$pyinstallerOutputDir\$executableName" -Destination "$targetDir\$executableName" -Force

# Clean up: remove the virtual environment and temporary build files
Remove-Item -Recurse -Force "$pythonProjectPath\venv"
Remove-Item -Recurse -Force "$pythonProjectPath\build"
Remove-Item -Recurse -Force "$pythonProjectPath\dist"
Remove-Item -Force "$pythonProjectPath\*.spec"

# Output a message indicating that the build and packaging process is complete
Write-Output "Build and packaging complete. The executable has been moved to $targetDir"
