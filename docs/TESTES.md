# Testes e critérios de aceite

Histórico iniciado em **11/11/2026**, com atualizações em **12/11/2026**. “Implementado” significa que existe código para o fluxo, não que uma operação em nuvem ou num dispositivo tenha sido comprovada.

## Estado atual confirmado pelo usuário

Em 12/11/2026, o usuário confirmou que o fluxo de QR funcionou. A evidência visual mostra **1 descoberta registrada** e **Amazônia Sustentável — Visitado** após a leitura pela câmera virtual. A leitura real e o check-in no aplicativo estão aprovados para esse cenário. O painel já foi acessado pelo usuário e os três estandes foram carregados no Android a partir do Firestore. A conferência independente do documento no console e a captura do contador do painel permanecem como evidências a registrar no vídeo.

A conta administrativa informada é **`usuario@gmail.com`**. Sua senha foi registrada somente em `docs/ACESSO_LOCAL.md`, ignorado pelo Git; não foi alterada no Firebase nem utilizada pelo agente para repetir login. A lista de pendências atuais inclui duplicidade real, QR inválido/inativo, testes de regras, Remote Config em tempo real, GA4 Tempo real e o fluxo de distribuição/instalação pelo App Distribution.

## Atualização de 12/11/2026 — dependências do painel

- Corrigido o Firebase 9.14.0 introduzido por `npm audit fix --force`; versão final fixada em 13.3.0.
- Aplicado override apenas em `@firebase/firestore → @grpc/grpc-js`, versão 1.14.7. `protobufjs` resolvido em 7.6.6, sem a cópia antiga 6.x.
- Dependências instaladas pelo npm usando os arquivos reais já disponíveis em cache; o lockfile foi atualizado e a instalação reproduzida com `npm ci --offline`.
- `npm run build`: TypeScript e Vite passaram; arquivos gerados em `admin-web/dist`. Há aviso de bundle maior que 500 kB, sem impedir o build.
- `npm test`: 19 testes aprovados em dois arquivos, agora usando a instalação completa do painel.
- Runner de domínio TypeScript: 20 testes aprovados.
- Importação do Firebase/Firestore e criação de referências/queries verificadas em Node 24.15, sem requisições a um projeto real.
- Comparação com 57 avisos diretos já armazenados no cache: nenhuma versão instalada correspondente. Evidência: [dependencias-2026-11-12.json](evidencias/dependencias-2026-11-12.json). Logs de [build](evidencias/build-admin-2026-11-12.txt) e [Vitest](evidencias/vitest-admin-2026-11-12.txt) preservados.
- Uma nova auditoria online continua pendente: a tentativa de `npm audit --json` falhou com `ENOTFOUND registry.npmjs.org`. Não foi alegado resultado online de zero vulnerabilidades.

O registro de 11/11 abaixo preserva os bloqueios daquela execução. O build do painel deixou de ser uma pendência; navegador, Firebase real, Flutter/AVD e distribuição mantêm seus estados anteriores.

## Atualização de 12/11/2026 — detecção do AVD

Com a restrição do ambiente removida, ADB e KVM foram verificados como funcionais. Não havia emulador em execução. `Small_Phone` foi iniciado a frio, sem apagar dados, e concluiu o boot com `sys.boot_completed=1`. ADB e Flutter passaram a listar `emulator-5554` em estado `device`, Android 10/API 29. O caminho do SDK foi salvo na configuração do Flutter. O script `scripts/start-android.sh` foi validado por sintaxe e pela identificação do AVD já aberto.

Evidências: [flutter devices](evidencias/flutter-devices-2026-11-12.txt) e [flutter doctor](evidencias/flutter-doctor-2026-11-12.txt). A detecção do AVD está validada; isso ainda não comprova instalação do aplicativo, leitura pela câmera ou integração com Firebase. O cadastro Firebase utiliza `circuito.descobertas`. Após confirmação do usuário, applicationId, namespace e MainActivity foram alinhados a esse identificador, preservando o JSON real e a chave de assinatura.

## Atualização de 12/11/2026 — pacote Android e execução real

O identificador Android foi alinhado ao cadastro real do usuário: `circuito.descobertas`. Foram atualizados applicationId, namespace, pacote e caminho da MainActivity e comandos de configuração/Analytics/distribuição na documentação. O nome do pacote Dart permanece `circuito_descobertas`. O JSON Firebase e o keystore existentes foram preservados.

- `flutter pub get`: aprovado.
- `flutter analyze --no-pub`: aprovado, nenhuma ocorrência; removido um import redundante do repositório Firestore.
- `flutter test --no-pub`: **40 testes aprovados**, incluindo os dois testes de widget.
- `flutter build apk --debug --no-pub`: aprovado. APK em `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- Manifest gerado e recursos Google Services conferidos com o identificador e App ID reais.
- Instalação por ADB: `Success`; abertura de `circuito.descobertas/.MainActivity`: `Status: ok`.
- Tela inicial no AVD `emulator-5554` carregou os três estandes fictícios reais do Firestore. Isso confirma a inicialização/autenticação e a leitura da lista; câmera, check-in, missão em tempo real, GA4 e distribuição ainda precisam de validação própria.

A primeira build levou aproximadamente cinco minutos e gerou avisos dos plugins sobre migração futura do Kotlin, além de notas de compilação do Firestore; não houve erro de build. Este APK é **debug**, não a release para o App Distribution.

Evidências: [build Android](evidencias/build-android-debug-2026-11-12.txt), [registro da validação](evidencias/pacote-android-2026-11-12.json) e [tela do aplicativo](evidencias/app-android-2026-11-12.png).

## Atualização de 12/11/2026 — controles da câmera virtual

Foi reproduzida a ausência do menu **Camera** no Android Emulator 37.1.11 com a traseira em `emulated`. Após backup do config.ini, troca persistente para `hw.camera.back=virtualscene` e reinicialização a frio, a opção passou a aparecer. A tela **Camera → Virtual scene images**, com **Wall/Table → Add Image**, foi aberta e inspecionada visualmente. O Android completou o boot e o aplicativo foi preservado. Evidência: [controles da câmera](evidencias/camera-virtualscene-2026-11-12.png). Esta validação confirma o recurso de importação disponível, não um check-in pela câmera.

## Atualização de 12/11/2026 — localização do QR na cena virtual

As imagens foram confirmadas nos dois slots **Wall** e **Table** dos controles. O QR não substitui a textura da TV: ele aparece como cartaz em outra parede e sobre a mesa da cena. Ao olhar para a TV, é necessário girar aproximadamente meia-volta e ajustar a posição lateral para enxergar o cartaz atrás do vão/coluna, então aproximar e enquadrar o código completo.

Durante a validação com o scanner real aberto, a tela passou a mostrar **1 descoberta registrada** e **Amazônia Sustentável — Visitado**. Evidência: [resultado indicado pelo aplicativo](evidencias/checkin-indicado-no-app-2026-11-12.png). Isso registra o sucesso indicado pelo fluxo do aplicativo; a conferência independente do documento no console Firestore, do contador do painel e do evento no GA4 deve ser feita na demonstração. Não houve alteração de código para simular a câmera ou o check-in.

## Scripts Windows — validação disponível

Foram criados `android-env.ps1`, `start-android.ps1`, `test-core.ps1` e o atalho `start-android.bat`. Os três scripts PowerShell passaram pela análise sintática com PowerShell portátil 7.7 no Linux. `test-core.ps1` executou os **38 testes Dart reais**, todos aprovados, usando o SDK instalado.

Com respostas simuladas de ADB/emulator em um SDK temporário com espaços no caminho, foram conferidos seis cenários: iniciar AVD com os argumentos corretos de VirtualScene, reaproveitar AVD aberto, rejeitar emulador offline, avisar sobre AVD ausente, preparar PATH sem duplicações e rejeitar SDK inexistente. Esses testes verificam a lógica dos scripts; não comprovam a execução de binários Windows.

O `.bat`, o PowerShell 5.1 e a inicialização do Android Emulator em Windows ainda precisam de teste em uma máquina Windows. Os scripts foram escritos com sintaxe compatível com PowerShell 5.1 e usam o SDK local daquele computador, sem caminhos do Linux. Veja os comandos em [COMO_RODAR.md](../COMO_RODAR.md).

## APK release — geração e assinatura verificadas em 12/11/2026

`flutter build apk --release` concluiu com sucesso em aproximadamente 149 segundos. O arquivo `mobile/build/app/outputs/flutter-apk/app-release.apk` contém o pacote `circuito.descobertas`, versão 1.0.0, código 1, e as arquiteturas arm64-v8a, armeabi-v7a e x86_64.

`apksigner verify --verbose --print-certs` confirmou assinatura v2 válida. O SHA-256 do certificado foi comparado com o certificado exportado do keystore release e correspondeu. O SHA-256 do APK e os metadados estão em [apk-release-2026-11-12.json](evidencias/apk-release-2026-11-12.json); as saídas estão em [build release](evidencias/build-android-release-2026-11-12.txt) e [assinatura](evidencias/assinatura-release-2026-11-12.txt).

A geração e a assinatura do release estão aprovadas. Não foram realizados upload, convite, instalação ou abertura pelo App Distribution. O app debug existente no AVD foi preservado.

## Histórico da execução inicial — 11/11/2026

| Verificação | Resultado real |
|---|---|
| `flutter doctor -v` | Executado com SDK copiado para `/tmp`; toolchain Android e licenças disponíveis; ADB/rede bloqueados |
| `flutter devices`, `adb devices` | Executados; servidor ADB não pode abrir socket: `Operation not permitted` |
| AVD | `Small_Phone`, Google APIs Android 29 x86_64, listado com `emulator -list-avds` |
| Lógica Dart | **38 testes passaram**, nenhum falhou, usando `scripts/test-core.sh` |
| Domínio TypeScript | **20 testes passaram**, nenhum falhou, usando `admin-web/scripts/test-domain.mjs` |
| Sintaxe TypeScript/TSX | 19 arquivos transpilados com TypeScript 5.9.3 recuperado do cache; nenhum erro de sintaxe. Não equivale a `tsc -b` ou build Vite |
| Formatação Dart | `dart format` executado em `lib`, `test` e `tool` |
| Análise estática parcial | Modelos, parser, serviço de check-in, tema, cartão e testes analisados em pacote temporário com SDK/cache reais: nenhuma ocorrência após correções |
| `flutter pub get` | Tentado; erro DNS em pub.dev. Em `--offline`, confirmou pacotes ausentes; FlutterFire/mobile_scanner não disponíveis no cache |
| `flutter analyze --no-pub` completo | Tentado; processo bloqueado por telemetria fora da área gravável. Análise direta pelo Dart também tentou o projeto completo e confirmou imports dos plugins ausentes; não houve aprovação integral |
| `flutter test --no-pub` | Tentado; runner não pode criar socket em `127.0.0.1`; testes de widgets não rodaram |
| `npm install`, painel e raiz | Tentados; `ENOTFOUND registry.npmjs.org`; tentativa offline também encontrou dependências ausentes |
| `npm run dev`, painel | Tentado; Vite indisponível na instalação incompleta; navegador não validado |
| `npm run build`, painel | Tentado; `tsc` indisponível após instalação incompleta |
| `npm test`, painel | **19 testes passaram em 2 arquivos**, após recuperação temporária dos pacotes runtime reais já em cache; instalação completa ainda pendente |
| `npm run test:rules` | Tentado; Firebase CLI indisponível. Suíte de segurança escrita, não executada |
| Scripts de regras/seed | `node --check` passou; não equivale a executar regras no emulador |
| Keystore release | Gerado localmente com senha aleatória; alias `circuito` verificado por `keytool -list`; arquivos privados com permissão `600` |
| Exclusão de segredos | `.gitignore` verificado com `git check-ignore` em repositório temporário: keystore, key.properties, JSON Android e .env.local excluídos |
| `flutter build apk --release --no-pub` | Tentado; cache Gradle somente leitura. Nova tentativa com cache temporário falhou em `Could not determine a usable wildcard IP` no sandbox; nenhum APK produzido |
| `git init` | Tentado; `.git/info` somente para leitura no workspace gerenciado |
| Firebase real, GA4 e App Distribution | Não executados; nenhum projeto real configurado/autenticado nesta sessão |

A suíte Vitest foi executada também na pasta original do painel, via `npm test`, com dependências runtime recuperadas do cache em `/tmp` e um link temporário de `node_modules`, removido após a verificação. Não foram criados stubs de bibliotecas. Os testes de componentes mockam somente o serviço de persistência, como declarado na suíte.

As saídas estão em [evidencias/testes-dart.txt](evidencias/testes-dart.txt), [evidencias/testes-dominio-web.txt](evidencias/testes-dominio-web.txt) e [evidencias/vitest-admin.txt](evidencias/vitest-admin.txt). Os dois conjuntos web têm cobertura parcialmente sobreposta.

A instalação original foi preservada. Nos testes do serviço, o banco é um double em memória; esses testes **não provam as regras Firestore**. Concorrência no servidor é alvo da suíte Firebase Emulator Suite pendente.

## Reproduzir as suítes completas

```bash
# Raiz, com rede e portas locais disponíveis
npm install
npm run test:rules
```

A CLI abre Auth/Firestore no projeto local **demo-circuito**, carrega as regras e executa usuários simulados. Não usa produção. O Firebase Emulator Suite é independente do Android Virtual Device e precisa baixar o emulador Java do Firestore na primeira execução.

```bash
cd admin-web
npm install
npm test
npm run build
```

Vitest cobre estatísticas, validação, contrato do QR e formulário de cadastro com serviço mockado. Não substitui o fluxo real Authentication/Firestore.

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Para domínio sem baixar dependências:

```bash
# Raiz, com Dart, Python 3 e Node 24
bash scripts/test-core.sh
node --disable-warning=ExperimentalWarning admin-web/scripts/test-domain.mjs
```

O runner Dart aponta para o próprio pacote por configuração temporária e executa os mesmos 38 casos de `core_test.dart`. Não cria stubs de SDKs. O runner Node usa os módulos TypeScript reais, remove somente a tipagem pelo Node 24 e executa `node:test`.

## Segurança coberta pela suíte escrita

- Sem autenticação e autenticação comum sem privilégio administrativo.
- Cadastro/edição de estandes apenas por administrador autorizado.
- Campos, tipos, limites, whitespace, campos extras e timestamps.
- Listagem de visitante com `ativo == true`, get individual de inativo permitido.
- Proibição de criar privilégios administrativos pelo cliente.
- Leitura do próprio check-in inexistente para a transação.
- UID próprio, ID determinístico, campos exatos e timestamp do servidor.
- Bloqueio de inexistente/inativo, sobrescrita, edição e exclusão.
- Isolamento entre visitantes, consulta administrativa e histórico preservado.
- Gravações e transações concorrentes deixando um único documento.

Não marque a suíte de regras como aprovada antes de `npm run test:rules` terminar com sucesso.

## QR real pela câmera do AVD

O AVD foi inicialmente encontrado com câmera `emulated` e já foi ajustado para `hw.camera.back=virtualscene`. Para reproduzir o teste em outro ambiente, configure **VirtualScene** e siga os passos:

1. No painel, abra QR Code de um estande ativo e clique em **Baixar PNG**. A imagem de 1024 pixels contém o ID real e margem branca.
2. Com o AVD desligado, edite a câmera traseira para VirtualScene no Device Manager ou inicie:

   ```bash
   emulator -avd Small_Phone -camera-back virtualscene
   ```

3. Abra o emulador em janela independente. Nos controles avançados (`…`), abra **Camera → Virtual scene images → Add image**. Se houver posições Wall/Table, carregue o PNG em uma delas.
4. Abra o scanner do aplicativo e permita a câmera.
5. Navegue na cena até enquadrar o QR. Use os atalhos mostrados pelo emulador; normalmente Alt + mouse gira a câmera e W/A/S/D/Q/E movem a posição. Aproxime e ajuste o tamanho até as células ficarem nítidas, com a margem branca visível.
6. Aguarde **Descoberta registrada!**. Confira o documento `checkins/UID_IDESTANDE`, seus IDs e timestamp no Firestore.
7. Veja o total por estande e o total geral aumentarem no painel sem reload.
8. Reabra o scanner e leia o mesmo QR: deve informar visita já registrada e não incrementar novamente.

O `mobile_scanner` usa o modelo ML Kit empacotado; o scanner não precisa baixá-lo na primeira utilização. O check-in precisa do servidor Firestore.

Se a opção não aparecer, confira imagem do AVD, versão do Android Emulator, câmera traseira, janela independente e Cold Boot. A [documentação Android](https://developer.android.com/studio/run/emulator-use-camera) descreve importação PNG/JPEG e QR em Virtual scene images.

Alternativa de **câmera no próprio emulador**: se houver webcam, configure a traseira como `webcam0`, imprima/exiba o QR em outra tela e enquadre-o pela webcam. A disponibilidade depende do host. A câmera virtual foi validada em 12/11 após a liberação do acesso ao AVD; a alternativa por webcam ainda não foi testada. Parser ou chamada direta ao serviço não substituem a câmera na gravação final.

## Matriz manual — situação atual

| Caso | Resultado esperado | Situação nesta sessão |
|---|---|---|
| Primeiro acesso | Usuário anônimo e lista carregada | Aprovado no AVD em 12/11 |
| Fechar/reabrir | Mesmo UID, sem limpar dados | Pendente |
| Admin autorizado | Login e dashboard | Painel acessado pelo usuário; credenciais informadas não revalidadas pelo agente |
| Conta sem admin | Acesso negado | Pendente |
| Cadastrar/editar | Firestore e mobile atualizados | Três estandes persistidos e lidos no app; edição ainda pendente de evidência |
| Desativar com visitas | Sai da lista; histórico no total | Pendente |
| Detalhes | Nome, descrição, localização, status | Aprovado visualmente para Amazônia Sustentável |
| Câmera negada | Mensagem, tentar novamente e configurações | Pendente |
| QR externo ou malformado | Erro; sem gravação/evento | Parser aprovado; câmera pendente |
| Estande ausente/inativo | Mensagem correta; sem gravação | Servidor/câmera pendentes |
| Check-in novo | Commit, confirmação, indicador, contador | Leitura e visita aprovadas no app e confirmadas pelo usuário; contador do painel a registrar |
| Check-in duplicado | Uma visita, um evento | Serviço aprovado; servidor pendente |
| Concorrência | Uma gravação confirma | Emulator Suite pendente |
| Offline após lista carregada | Cache visível; sem confirmação falsa | Pendente |
| Reconexão | Check-in ou aviso de duplicidade real | Pendente |
| Missão OFF | Lista sem banner, check-in disponível | Estado aprovado; console pendente |
| Missão ON e OFF no mesmo APK | Banner e destaques aparecem/desaparecem | Console pendente |
| JSON remoto inválido | Sem crash, participantes vazios | Parsing aprovado; console pendente |
| Desativar missão aberta | Mensagem de encerramento | Pendente |
| Analytics | Dois eventos no Tempo real, estande_id | Pendente |
| Distribuição/testador | Release acessada, instalada e aberta | Pendente |

### Imagens negativas para ensaio

Com as dependências do painel instaladas, gere PNGs e importe-os na câmera virtual:

```bash
cd admin-web
node --input-type=module -e "import QRCode from 'qrcode'; await QRCode.toFile('qr-externo.png', 'outro://teste', {width:1024,margin:4});"
node --input-type=module -e "import QRCode from 'qrcode'; await QRCode.toFile('qr-inexistente.png', 'circuito://estande/inexistente', {width:1024,margin:4});"
```

Para inativo, use o QR original salvo e desative o estande pelo painel. Prepare estandes/identidades antes do vídeo, sem fabricar contagens ou apagar histórico para a gravação.

## Critérios finais de aceite

| Critério | Implementação/preparação | Validação real |
|---|---|---|
| Painel React protegido | Implementado | Build e 19 testes aprovados; acesso no navegador confirmado pelo usuário |
| Login autorizado e CRUD | Implementados | Painel utilizado pelo usuário e estandes reais carregados; testes negativos/edição pendentes |
| Lista e detalhes Flutter | Implementados | Lista e detalhes de Amazônia Sustentável aprovados no AVD |
| Scanner e QR do painel | Implementados | Leitura real aprovada; visita de Amazônia Sustentável confirmada |
| Check-in único e bloqueio de inativo | Transação/regras implementadas | Check-in válido aprovado; duplicidade real, inativo e Emulator Suite pendentes |
| Dashboard automático | Listeners implementados | Firebase pendente |
| Remote Config sem reinstalação | Listener e estados implementados | Console pendente |
| Analytics com estande_id | Ordem validada no domínio | GA4 Tempo real pendente |
| APK assinado | Release 1.0.0 gerado com keystore próprio | Build e apksigner aprovados; instalação pelo App Distribution pendente |
| App Distribution | Procedimento documentado | Upload/convite/instalação pendentes |
| Testes/builds completos | Suítes criadas e executadas | 40 testes Flutter, análise Flutter, 19 testes web, build web, APK debug e APK release assinado aprovados; regras e distribuição pendentes |
| Reprodução/vídeo | Documentação e roteiro prontos | Ensaio integrado pendente |

A implementação não é declarada integralmente validada enquanto essas pendências não forem resolvidas. As ações de conta estão em CONFIGURACAO_FIREBASE.md e DISTRIBUICAO_APK.md; não exigem desenvolver manualmente funcionalidades centrais.
