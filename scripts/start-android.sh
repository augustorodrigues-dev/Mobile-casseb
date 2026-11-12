#!/usr/bin/env bash
# Inicia o AVD pelo terminal do VS Code, preservando seus dados.
set -euo pipefail
circuito_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$circuito_script_dir/android-env.sh"
circuito_avd_name="${1:-Small_Phone}"
circuito_adb="$ANDROID_HOME/platform-tools/adb"
circuito_emulator="$ANDROID_HOME/emulator/emulator"

if [[ ! -x "$circuito_adb" || ! -x "$circuito_emulator" ]]; then
  echo "ADB ou Android Emulator não encontrado em ANDROID_HOME=$ANDROID_HOME" >&2
  exit 1
fi
"$circuito_adb" start-server
while read -r circuito_serial circuito_state circuito_rest; do
  [[ "$circuito_serial" == emulator-* && "$circuito_state" == device ]] || continue
  circuito_running_name="$("$circuito_adb" -s "$circuito_serial" emu avd name 2>/dev/null | tr -d '\r' | head -n 1)"
  if [[ "$circuito_running_name" == "$circuito_avd_name" ]]; then
    echo "AVD $circuito_avd_name já está disponível em $circuito_serial."
    flutter devices
    exit 0
  fi
done < <("$circuito_adb" devices)

if ! "$circuito_emulator" -list-avds | tr -d '\r' | rg -F -x -- "$circuito_avd_name" >/dev/null; then
  echo "AVD não encontrado: $circuito_avd_name" >&2
  "$circuito_emulator" -list-avds
  exit 1
fi
echo "Iniciando $circuito_avd_name. Aguarde a tela inicial do Android."
echo "Mantenha este terminal aberto e execute flutter run em outro terminal."
exec "$circuito_emulator" -avd "$circuito_avd_name" -no-snapshot-load -camera-back virtualscene
