$arbs = @(
    "./lib/l10n/arb/intl_de.arb",
    "./lib/l10n/arb/intl_en.arb",
    "./lib/l10n/arb/intl_es.arb",
    "./lib/l10n/arb/intl_fr.arb",
    "./lib/l10n/arb/intl_it.arb"
)

# Loop through each file path and execute the command
foreach ($arb in $arbs) {
    $command = "arb_utils sort $arb"
    Write-Host "Running command: $command"
    Invoke-Expression $command
}

# After processing ARB files, run `flutter pub get`
Write-Host "Running: flutter pub get"
flutter pub get

# Output a message indicating that the code generation process is complete
Write-Output "Intl file generation complete"
