#!/bin/bash

# Array of ARB file paths
arbs=(
    "./lib/l10n/arb/intl_de.arb"
    "./lib/l10n/arb/intl_en.arb"
    "./lib/l10n/arb/intl_es.arb"
    "./lib/l10n/arb/intl_fr.arb"
    "./lib/l10n/arb/intl_it.arb"
)

# Loop through each file path and execute the command
for arb in "${arbs[@]}"; do
    command="arb_utils sort $arb"
    echo "Running command: $command"
    eval $command
done

# After processing ARB files, run `flutter pub get`
echo "Running: flutter pub get"
flutter pub get

# Output a message indicating that the code generation process is complete
echo "Intl file generation complete"
