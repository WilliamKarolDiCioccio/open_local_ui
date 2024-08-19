# Define the Flutter download URL
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.13.0-stable.zip"

# Define the installation directory
$flutterDir = "$env:RUNNER_TEMP\flutter"

# Download the Flutter zip archive
Invoke-WebRequest -Uri $flutterUrl -OutFile "$env:RUNNER_TEMP\flutter.zip"

# Extract the Flutter zip archive
Expand-Archive "$env:RUNNER_TEMP\flutter.zip" -DestinationPath $flutterDir

# Add Flutter to the PATH by updating the GITHUB_ENV
$flutterBinPath = "$flutterDir\flutter\bin"
Write-Output "FLUTTER_HOME=$flutterBinPath" >> $env:GITHUB_ENV
Write-Output "PATH=$flutterBinPath;$env:PATH" >> $env:GITHUB_ENV
