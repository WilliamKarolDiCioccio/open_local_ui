param(
    [string]$config = "debug"
)

# Define base command for build
$baseBuildCommand = "flutter build windows"

# Map configurations to their respective output paths
$buildCommands = @{
    "debug"  = "$baseBuildCommand --debug"
    "release"= "$baseBuildCommand --release --obfuscate --split-debug-info=/build/debug_info --extra-gen-snapshot-options=--save-obfuscation-map=/build/obfuscation_map.json"
}

# Check if the provided configuration is valid
if (-not $buildCommands.ContainsKey($config)) {
    Write-Error "Invalid configuration. Please use 'debug' or 'release'."
    exit 1
}

# Run the build command based on the provided configuration
Invoke-Expression -Command $buildCommands[$config]

# Output a message indicating that the build and packaging process is complete
Write-Output "Build and packaging complete"
