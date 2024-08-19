# Set script to exit on any error
$ErrorActionPreference = "Stop"

# Step 1: Install Chocolatey using winget
Write-Host "Installing Chocolatey..."
winget install --id Chocolatey.Choco -e --source msstore

# Refresh environment variables to include Chocolatey
$env:Path += ";$env:ChocolateyInstall\bin"

# Step 2: Install Flutter using Chocolatey
Write-Host "Installing Flutter via Chocolatey..."
choco install flutter --confirm

# Step 3: Add Flutter to the system PATH
$flutterPath = [System.IO.Path]::Combine($env:ChocolateyInstall, 'lib\flutter\tools\flutter\bin')
$globalPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$globalPath += ";$flutterPath"
[System.Environment]::SetEnvironmentVariable("Path", $globalPath, [System.EnvironmentVariableTarget]::Machine)

# Refresh the environment for the current session
$env:Path = $globalPath

# Set Flutter path in GitHub environment
$githubEnvPath = "${env:GITHUB_ENV}"
Add-Content -Path $githubEnvPath -Value "FLUTTER_BIN_PATH=$flutterPath"
Add-Content -Path $githubEnvPath -Value "PATH=$globalPath"

# Step 4: Verify Flutter installation
Write-Host "Verifying Flutter installation..."
flutter --version

# Step 5: Run Flutter doctor to ensure installation is complete
Write-Host "Running Flutter doctor to finalize setup..."
flutter doctor

# Step 6: Set up caching environment variables
Write-Host "Setting up cache environment variables..."

# Define default cache paths and keys
$CACHE_PATH = "C:\flutter_cache\flutter"
$CACHE_KEY = "flutter-cache-key"
$PUB_CACHE_PATH = "C:\flutter_cache\pub"
$PUB_CACHE_KEY = "flutter-pub-cache-key"

# Set cache environment variables in the current session and GitHub environment
[System.Environment]::SetEnvironmentVariable("CACHE_PATH", $CACHE_PATH, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("CACHE_KEY", $CACHE_KEY, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PUB_CACHE_PATH", $PUB_CACHE_PATH, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PUB_CACHE_KEY", $PUB_CACHE_KEY, [System.EnvironmentVariableTarget]::Machine)

# Write environment variables to GITHUB_ENV for use in subsequent steps
Add-Content -Path $githubEnvPath -Value "CACHE_PATH=$CACHE_PATH"
Add-Content -Path $githubEnvPath -Value "CACHE_KEY=$CACHE_KEY"
Add-Content -Path $githubEnvPath -Value "PUB_CACHE_PATH=$PUB_CACHE_PATH"
Add-Content -Path $githubEnvPath -Value "PUB_CACHE_KEY=$PUB_CACHE_KEY"

Write-Host "Cache environment variables set:"
Write-Host "CACHE_PATH=$CACHE_PATH"
Write-Host "CACHE_KEY=$CACHE_KEY"
Write-Host "PUB_CACHE_PATH=$PUB_CACHE_PATH"
Write-Host "PUB_CACHE_KEY=$PUB_CACHE_KEY"

Write-Host "Flutter installation and cache setup completed successfully!"
