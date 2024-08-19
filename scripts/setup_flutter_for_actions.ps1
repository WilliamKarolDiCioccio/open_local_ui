# Set script to exit on any error
$ErrorActionPreference = "Stop"

# Step 1: Download Flutter SDK bundle
Write-Host "Downloading Flutter SDK..."
$flutterVersion = "3.24.0-stable"
$downloadUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$flutterVersion.zip"
$downloadPath = "$env:USERPROFILE\Downloads\flutter_windows_$flutterVersion.zip"

Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Step 2: Create installation directory
Write-Host "Creating installation directory..."
$installDir = "$env:USERPROFILE\dev\flutter"
New-Item -Path $installDir -ItemType Directory -Force

# Step 3: Extract Flutter SDK to the installation directory
Write-Host "Extracting Flutter SDK..."
Expand-Archive -Path $downloadPath -DestinationPath $installDir -Force

# Step 4: Add Flutter to the system PATH
$flutterBinPath = [System.IO.Path]::Combine($installDir, 'flutter\bin')
$globalPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if (-not ($globalPath -contains $flutterBinPath)) {
    $globalPath += ";$flutterBinPath"
    [System.Environment]::SetEnvironmentVariable("Path", $globalPath, [System.EnvironmentVariableTarget]::Machine)
}

# Refresh the environment for the current session
$env:Path = $globalPath

# Step 5: Verify Flutter installation
Write-Host "Verifying Flutter installation..."
flutter --version

# Step 6: Run Flutter doctor to ensure installation is complete
Write-Host "Running Flutter doctor to finalize setup..."
flutter doctor

# Step 7: Set up caching environment variables
Write-Host "Setting up cache environment variables..."

# Define default cache paths and keys
$CACHE_PATH = "C:\flutter_cache\flutter"
$CACHE_KEY = "flutter-cache-key"
$PUB_CACHE_PATH = "C:\flutter_cache\pub"
$PUB_CACHE_KEY = "flutter-pub-cache-key"

# Set cache environment variables
[System.Environment]::SetEnvironmentVariable("CACHE_PATH", $CACHE_PATH, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("CACHE_KEY", $CACHE_KEY, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PUB_CACHE_PATH", $PUB_CACHE_PATH, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PUB_CACHE_KEY", $PUB_CACHE_KEY, [System.EnvironmentVariableTarget]::Machine)

Write-Host "Cache environment variables set:"
Write-Host "CACHE_PATH=$CACHE_PATH"
Write-Host "CACHE_KEY=$CACHE_KEY"
Write-Host "PUB_CACHE_PATH=$PUB_CACHE_PATH"
Write-Host "PUB_CACHE_KEY=$PUB_CACHE_KEY"

Write-Host "Flutter installation and cache setup completed successfully!"
