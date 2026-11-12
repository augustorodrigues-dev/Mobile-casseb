#!/usr/bin/env bash
# Execute com source scripts/android-env.sh na raiz do projeto.
export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
# Evita o launcher Snap quando o SDK já foi instalado por ele.
if [ -x "$HOME/snap/flutter/common/flutter/bin/flutter" ]; then
  export PATH="$HOME/snap/flutter/common/flutter/bin:$PATH"
fi
