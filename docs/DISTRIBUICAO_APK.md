# Assinatura, APK e Firebase App Distribution

O fluxo usa um APK assinado e Firebase App Distribution, sem Google Play e sem plano Blaze. **Em 12/11/2026, o APK release 1.0.0 (build 1) foi gerado e sua assinatura foi validada.** O pacote é `circuito.descobertas`; o arquivo está em `mobile/build/app/outputs/flutter-apk/app-release.apk` (aproximadamente 67 MB). O upload, o convite e a instalação por testador ainda estão pendentes.

## Assinatura preparada nesta máquina

Foi gerado um keystore release real em `mobile/android/app/circuito-release.jks`, alias `circuito`, e a senha aleatória foi gravada somente em `mobile/android/key.properties`. Os dois arquivos têm permissão local `600` e são ignorados pelo Git. O alias e o certificado foram verificados com `keytool`. O APK release também passou pelo `apksigner verify --verbose --print-certs`: a assinatura v2 é válida e o certificado SHA-256 corresponde ao keystore release.

Se estiver trabalhando nesta mesma pasta, preserve esses arquivos. Faça backup seguro de ambos. Não é necessário gerar outra chave para cada build. Ao clonar o repositório em outra máquina, os arquivos não estarão presentes: restaure seu backup ou siga a geração abaixo. Senhas e chaves privadas não devem aparecer no vídeo.

## Resultado da geração nesta máquina

- Comando executado: `flutter build apk --release`.
- Versão: **1.0.0**, código **1**; pacote: **circuito.descobertas**.
- Arquiteturas incluídas: `arm64-v8a`, `armeabi-v7a` e `x86_64`.
- Assinatura: verificada, com certificado do keystore release existente.
- Arquivo: `mobile/build/app/outputs/flutter-apk/app-release.apk`.
- Evidências: [build release](evidencias/build-android-release-2026-11-12.txt), [verificação de assinatura](evidencias/assinatura-release-2026-11-12.txt) e [metadados/SHA-256](evidencias/apk-release-2026-11-12.json).

O próximo passo é seguir **Enviar pelo console**, abaixo, e distribuir este APK pelo App Distribution. O aplicativo debug do AVD não foi removido; a instalação release como testador deve ser feita pelo fluxo de distribuição para a evidência do vídeo.

## Gerar uma chave em outra instalação

No terminal do VS Code, com `keytool` disponível no JDK:

```bash
mkdir -p "$HOME/.android/keys"
keytool -genkeypair -v \
  -keystore "$HOME/.android/keys/circuito-release.jks" \
  -storetype JKS -alias circuito \
  -keyalg RSA -keysize 2048 -validity 10000
```

Digite senhas próprias nos prompts. Os dados do certificado podem identificar a organização acadêmica fictícia. Não coloque a senha na linha de comando nem no controle de versão.

Copie `mobile/android/key.properties.example` para `mobile/android/key.properties` e edite localmente:

```properties
storeFile=/CAMINHO/ABSOLUTO/circuito-release.jks
storePassword=SUA_SENHA_LOCAL
keyAlias=circuito
keyPassword=SUA_SENHA_DA_CHAVE
```

`storeFile` é absoluto ou relativo à pasta `mobile/android`, conforme o `rootProject.file()` da configuração. No keystore já gerado nesta sessão, o valor é `app/circuito-release.jks`. No Windows, use barras `/` no caminho ou escape as barras invertidas do formato `.properties`.

O Gradle carrega esse arquivo e configura `signingConfigs.release`. Não há fallback de release para chave debug. Uma solicitação de release sem assinatura ou sem o JSON Firebase real falha com uma mensagem de configuração.

## Gerar e verificar APK

Configure primeiro `google-services.json`, Authentication, Firestore, Remote Config e Analytics conforme [CONFIGURACAO_FIREBASE.md](CONFIGURACAO_FIREBASE.md).

```bash
# Raiz
source scripts/android-env.sh
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O APK universal é adequado ao AVD x86_64 e aos dispositivos ARM suportados pelo Flutter. Não use `--split-per-abi` para seguir esse caminho único da demonstração.

Arquivo esperado:

```text
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Verifique usando a versão de build-tools instalada (no diagnóstico: `36.0.0`):

```bash
"$ANDROID_HOME/build-tools/36.0.0/apksigner" verify --verbose --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
keytool -list -v -keystore android/app/circuito-release.jks -alias circuito
```

Compare o SHA-256 do certificado informado pelo `apksigner` com o do keystore. A verificação precisa terminar com sucesso. Para uma impressão digital do arquivo distribuído:

```bash
sha256sum build/app/outputs/flutter-apk/app-release.apk
```

Uma nova versão deve aumentar `version: 1.0.0+1` no `pubspec.yaml`, por exemplo para `1.0.1+2`, mantendo o mesmo package name e a mesma chave. Um APK debug com o mesmo pacote usa outra assinatura: para instalar o release no AVD que tinha debug, pode ser necessário desinstalar o debug uma única vez **antes** da gravação, o que apaga o UID anônimo. Não reinstale entre a ativação e a desativação da missão.

## Enviar pelo console

1. Firebase → App Distribution → selecione o app Android do pacote `circuito.descobertas`.
2. Começar → arraste **o APK release verificado**, não o arquivo debug.
3. Aguarde o processamento e confira versão, número de build e aplicação.
4. Adicione o e-mail real de um testador e notas como “Demonstração acadêmica com dados fictícios”.
5. Clique em Distribuir e confira o status do convite e a release listada.

O upload e o envio de convite dependem da sua conta e da identidade do testador. Nenhuma dessas operações foi efetuada automaticamente.

### Alternativa pela CLI

Na raiz, com a CLI instalada e login concluído:

```bash
npx firebase login
npx firebase appdistribution:distribute \
  mobile/build/app/outputs/flutter-apk/app-release.apk \
  --app SEU_FIREBASE_APP_ID_ANDROID \
  --testers "EMAIL_REAL_DO_TESTADOR" \
  --release-notes "Circuito de Descobertas — demonstração acadêmica" \
  --project SEU_ID_REAL
```

O `--app` recebe o Firebase App ID Android, no formato `1:...:android:...`, encontrado nas configurações do app; não é o package name. Confira os links e o resultado retornados pela CLI. Não use tokens ou conta de serviço em arquivos versionados.

## Aceitar, instalar e abrir

1. No Android de teste ou navegador do AVD, abra o convite recebido e entre com a conta Google correspondente ao testador convidado.
2. Aceite o convite e abra a versão oferecida pelo App Distribution, por navegador ou pelo aplicativo de testadores quando oferecido.
3. Baixe o APK pela página da release.
4. Se solicitado, autorize **Instalar apps desconhecidos** para o navegador/instalador usado. Conclua a instalação.
5. Toque em Abrir e confira a tela Circuito de Descobertas, lista de estandes e permissão de câmera.
6. Registre a instalação e a abertura no vídeo, além da release e do testador no console.

O AVD `Small_Phone` possui Google APIs, mas não Play Store. O fluxo por navegador permite baixar o APK; a experiência de conta Google e do aplicativo de testadores precisa ser conferida no dispositivo. Se a imagem limitar esse fluxo, crie um AVD com imagem Google Play e navegador/conta de teste. O APK não depende de publicação na Play Store.

Para diagnóstico local também existe `adb -s emulator-5554 install -r CAMINHO_DO_APK`, mas instalação via ADB não comprova que o testador acessou e instalou a versão distribuída. A evidência principal deve mostrar o convite, a release acessada e a instalação pelo fluxo de distribuição.

## Evidências

- Saída real de `apksigner verify`, versão do APK e certificado correspondente.
- Release no Firebase App Distribution e testador convidado.
- Aceite do convite, acesso à versão, instalação e abertura do app.
- Missão ligada e desligada no mesmo APK instalado, sem novo build.

Fontes: [assinatura e APK no Flutter](https://docs.flutter.dev/deployment/android), [App Distribution pela CLI](https://firebase.google.com/docs/app-distribution/android/distribute-cli).
