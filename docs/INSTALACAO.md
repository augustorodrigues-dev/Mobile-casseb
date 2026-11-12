# Instalação e execução pelo VS Code

## Ferramentas

- Flutter estável 3.47.9, Dart 3.13.7 e extensões Flutter/Dart no VS Code.
- Node.js 24.12 ou superior na linha 24 LTS e npm. Python 3 é usado somente no script opcional de testes de domínio.
- Android Studio para SDK Manager e Device Manager, Android SDK, platform-tools/ADB, build-tools e imagem Google APIs ou Google Play.
- JDK compatível com o Gradle do template (gerado com Gradle 9.3.1). O diagnóstico local encontrou JDK 21 no sistema e JBR 25 no Android Studio; `flutter doctor -v` informa qual está sendo usado.
- Git e Firebase CLI, instalada como dependência de desenvolvimento da raiz.

Abra a pasta raiz no VS Code e use Terminal → Novo terminal. Comandos iniciados na raiz são identificados abaixo; não é necessário abrir o projeto no editor do Android Studio.

```bash
source scripts/android-env.sh
flutter --version
dart --version
java -version
node --version
npm --version
flutter doctor -v
flutter devices
adb devices
emulator -list-avds
```

O script configura variáveis somente no terminal atual. Caso seu SDK esteja em outro caminho, exporte `ANDROID_HOME` antes de executá-lo. No Windows, configure `ANDROID_HOME` nas variáveis do usuário e inclua `platform-tools` e `emulator` no PATH. Não substitua uma instalação funcional desnecessariamente.

## Resultado do diagnóstico em 11/11/2026

| Item | Resultado observado |
|---|---|
| Sistema | Zorin OS 18.1, base Ubuntu 24.04, x86_64 |
| Flutter/Dart | 3.47.9 estável / 3.13.7, SDK do Snap disponível |
| Launcher `/snap/bin/flutter` | Falhou ao rastrear processo Snap nesta sessão |
| Execução alternativa | Cópia do SDK em `/tmp/circuito-tools/flutter`, sem alterar instalação original |
| Android SDK | `/home/augusto/Android/Sdk`, licenças aceitas |
| AVD | `Small_Phone`, Android 29, Google APIs x86_64 |
| Câmera do AVD | Traseira e frontal configuradas como `emulated`; usar `virtualscene` para PNG |
| JDK | OpenJDK 21 no terminal; Flutter detectou JBR 25 do Android Studio |
| Node/npm | 24.15.0 / 11.12.1 |
| ADB | Executável presente, servidor bloqueado pelo sandbox: `Operation not permitted` |
| Rede do terminal | DNS de npm, pub.dev e Maven indisponível nesta sessão |
| Git | `git init` bloqueado: `.git/info` somente para leitura |

As restrições de sandbox não comprovam defeito na sua instalação. O terminal normal do VS Code pode ter acesso que esta sessão não possui. Não foram alterados DNS, serviços Snap, licenças ou permissões do sistema.

## Configurar Firebase

Siga primeiro [CONFIGURACAO_FIREBASE.md](CONFIGURACAO_FIREBASE.md). Sem o projeto real, use o modo Emulator Suite descrito no README para testar Authentication/Firestore localmente.

```bash
# Raiz
npm install
# Painel
cd admin-web
cp .env.example .env.local
# Edite .env.local com a configuração pública web
npm install
npm run dev
```

Abra a URL exibida no terminal. Faça login com **`usuario@gmail.com`**, conta administrativa informada para a demonstração, usando a senha disponível em `docs/ACESSO_LOCAL.md` (arquivo local ignorado pelo Git). O UID da conta precisa estar autorizado em `admins/UID`. Uma conta apenas autenticada recebe uma tela de acesso negado.

Clique em **Carregar estandes de demonstração**. A operação cria somente os exemplos ausentes e preserva edições existentes. Todos os registros são persistidos no Firestore conectado.

## Criar ou abrir o AVD

O AVD existente é `Small_Phone`. Para criá-lo em outro computador:

1. Android Studio → More Actions → Virtual Device Manager, ou Tools → Device Manager.
2. Create Device → telefone Pixel/Small Phone.
3. Selecione imagem x86_64 Google APIs ou Google Play, API 29 ou superior. O aplicativo exige Android 7/API 24 ou superior.
4. Nas opções avançadas, habilite câmera traseira com **VirtualScene** para testar QR por imagem; a opção `Emulated` mostra a cena básica e não equivale ao recurso de imagens virtuais.
5. Inicie o dispositivo e aguarde o Android terminar de abrir.

Também pode iniciar pelo terminal, sem editor do Android Studio:

```bash
emulator -avd Small_Phone -camera-back virtualscene
adb devices
flutter devices
```

Não inicie uma segunda instância do mesmo AVD já aberto. Se editar a câmera pelo Device Manager, desligue e faça Cold Boot quando necessário.

### Iniciar o AVD pelo projeto

Na raiz, use `bash scripts/start-android.sh`. O script utiliza o SDK configurado, verifica se `Small_Phone` já está disponível e, se necessário, inicia o AVD sem carregar snapshot e com câmera traseira VirtualScene. Os dados do dispositivo são preservados. Mantenha o terminal do emulador aberto e execute o Flutter em outro terminal. Um nome diferente pode ser passado como argumento.

Em 12/11/2026, com acesso completo ao computador, foi confirmado que SDK, ADB e KVM estavam funcionais, mas nenhum processo de emulador estava em execução. O AVD foi iniciado a frio e concluiu o boot (`sys.boot_completed=1`). `adb devices -l` e `flutter devices` passaram a listar `emulator-5554` como dispositivo Android 10/API 29. O caminho `/home/augusto/Android/Sdk` foi salvo com `flutter config --android-sdk`. As restrições do diagnóstico inicial não se aplicam à sessão com acesso completo.

### Camera ausente nos controles avançados

Na versão 37.1.11 instalada, a opção **Camera** dos Extended Controls fica oculta quando a câmera traseira está configurada como `emulated`. Em 12/11/2026, o AVD foi encerrado normalmente, seu `config.ini` foi copiado para backup e `hw.camera.back` foi alterado para `virtualscene`. Após reiniciar sem snapshot, **Camera** apareceu abaixo de **Battery**, com a aba **Virtual scene images** e os botões **Add Image** nas posições **Wall** e **Table**. A configuração é persistente, inclusive ao iniciar pelo Device Manager/Flutter, e os dados do aplicativo foram preservados.

## Scripts equivalentes no Windows

Os scripts Windows usam PowerShell 5.1 ou superior e acompanham o projeto no Drive. Não é necessário instalar Bash, Python ou ripgrep para esses scripts. Instale Flutter e Android SDK antes.

| Linux/Bash | Windows | Função |
|---|---|---|
| `android-env.sh` | `android-env.ps1` | Configura SDK e PATH no terminal atual |
| `start-android.sh` | `start-android.ps1` ou `start-android.bat` | Abre AVD com câmera VirtualScene sem apagar dados |
| `test-core.sh` | `test-core.ps1` | Executa testes puros Dart sem baixar pacotes |

Na raiz do projeto, em CMD ou PowerShell:

```powershell
.\scripts\start-android.bat
# Para um nome e caminho diferentes:
.\scripts\start-android.bat -AvdName "NomeDoSeuAVD" -SdkPath "D:\Android\Sdk"
```

O `.bat` chama o PowerShell do Windows com política de execução limitada ao processo. Para executar diretamente os `.ps1` e preparar o terminal de desenvolvimento:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\android-env.ps1
# Também aceita: .\scripts\android-env.ps1 -SdkPath "D:\Android\Sdk"
flutter doctor -v
flutter devices
.\scripts\test-core.ps1
```

O SDK é procurado em `ANDROID_HOME`, `ANDROID_SDK_ROOT` e no caminho padrão `%LOCALAPPDATA%\Android\Sdk`; um `-SdkPath` explícito tem prioridade. A pasta `flutter\bin` precisa estar no PATH. O AVD padrão é `Small_Phone`; se faltar, o script mostra os AVDs locais. Um AVD já aberto é reaproveitado; um emulador offline gera orientação para aguardar ou reiniciar pelo Device Manager.

As variáveis e a política temporária afetam somente o processo atual, conforme a [documentação do PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables). Não há alteração permanente de PATH ou de política do Windows.

## Executar Flutter

```bash
# Raiz
source scripts/android-env.sh
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```

Substitua `emulator-5554` pelo ID real. Com mais de um dispositivo, sempre use `-d ID`; para ADB, use `adb -s ID ...`. No terminal do `flutter run`, `r` faz hot reload, `R` reinicia e `q` encerra. O `launch.json` permite executar via F5 pelo VS Code, escolhendo a configuração real ou local.

Na primeira execução, aceite a permissão de câmera ao entrar no scanner. A identidade anônima persiste no armazenamento nativo do Firebase Auth. Hot reload, fechamento e reabertura mantêm o UID; limpar os dados ou desinstalar troca a identidade e permite novas visitas como outro visitante.

## Builds

```bash
cd admin-web
npm run build
npm run preview
```

```bash
cd mobile
flutter build apk --debug
# Release exige configuração e keystore próprios
flutter build apk --release
```

Os arquivos do Vite ficam em `admin-web/dist/`. A assinatura e distribuição estão em [DISTRIBUICAO_APK.md](DISTRIBUICAO_APK.md). Após a primeira resolução bem-sucedida, mantenha os `package-lock.json` e `mobile/pubspec.lock` gerados para reproduzir versões. Não foi fabricado lockfile de dependências que o ambiente não conseguiu baixar.

## Auditoria das dependências npm

Em 12/11/2026, foi corrigido um rebaixamento provocado por `npm audit fix --force`, que havia trocado o Firebase por 9.14.0. O painel fixa `firebase: 13.3.0` e mantém um override restrito a `@firebase/firestore → @grpc/grpc-js: 1.14.7`. O lockfile conserva `protobufjs: 7.6.6`.

O override é necessário porque o Firestore 4.20.0 ainda solicita a linha gRPC `~1.9.0`, afetada pelo [aviso de autenticação do gRPC](https://github.com/grpc/grpc-node/security/advisories/GHSA-m9gg-hp2v-232j). A versão 1.14.7 também contém a correção do [vazamento de mensagens de erro](https://github.com/grpc/grpc-node/security/advisories/GHSA-f596-whhp-79r4). Revise esse override quando uma versão futura do SDK atualizar sua própria faixa de dependência.

Use o lockfile para reproduzir a instalação e examine a auditoria antes de aplicar mudanças:

```bash
cd admin-web
npm ci
npm audit
npm test
npm run build
```

Evite repetir `npm audit fix --force`: o resolvedor pode alternar versões principais e reintroduzir dependências antigas. Os avisos de depreciação de `@opentelemetry/sdk-trace-base`/`sdk-trace-web` vêm das dependências de Crashlytics incluídas no pacote Firebase. Sua atualização interna depende do SDK; não foram feitas substituições incompatíveis dessas APIs.

A instalação por lockfile, os testes e o build foram verificados localmente. A nova consulta online ao `npm audit` ficou bloqueada pelo DNS desta sessão. A comparação com os avisos já armazenados no cache não encontrou correspondências para as versões finais; ela não substitui uma auditoria atual no seu terminal com internet.

## Diagnóstico de problemas

- **Snap não inicia:** tente o SDK já existente diretamente, por exemplo `$HOME/snap/flutter/common/flutter/bin/flutter doctor -v`. O script de ambiente prioriza esse caminho quando existir.
- **ADB não encontrado:** confira `ANDROID_HOME` e PATH. `adb devices` precisa listar `device`, não `offline`/`unauthorized`. Aguarde o boot ou faça Cold Boot pelo Device Manager.
- **`Operation not permitted` ao abrir sockets:** execute no terminal normal, fora do sandbox restrito. ADB, Vite, testes Flutter e Emulator Suite precisam de portas locais.
- **`ENOTFOUND`, `Failed host lookup` ou pacotes ausentes:** restaure o acesso à rede antes de instalar. `--offline` não resolve pacotes que nunca foram baixados.
- **Firebase não configurado:** confira aplicação Android e package name, `google-services.json` e `.env.local`, e reinicie/recompile quando alterar configuração nativa.
- **`operation-not-allowed`:** habilite autenticação anônima ou e-mail/senha no projeto correto.
- **Permissão Firestore:** publique as regras deste repositório e confira `admins/UID`. No mobile, a listagem é uma query `ativo == true`.
- **Lista vazia:** confirme que os documentos existem no mesmo projeto e têm `ativo: true` booleano. Use o botão de demonstração com o administrador autorizado.
- **Câmera indisponível:** confira `virtualscene`, permissão do app e ausência de outro app usando a câmera. Há botão para abrir as configurações do Android.
- **Sem internet no app:** a lista em cache pode continuar visível, mas transações de check-in precisam do servidor. O app não confirma uma visita offline.
- **Logs:** use o console do `flutter run` ou `adb logcat`. Não compartilhe tokens ou arquivos privados nos logs.

Fontes: [Flutter: Android setup](https://docs.flutter.dev/platform-integration/android/setup), [criação de AVDs](https://developer.android.com/studio/run/managing-avds), [câmera do Android Emulator](https://developer.android.com/studio/run/emulator-use-camera).
