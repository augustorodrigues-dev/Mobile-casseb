# Configuração do Firebase Spark

Esta etapa depende de uma conta Google com acesso ao projeto. Nenhuma credencial real foi criada nesta sessão. As aplicações estão prontas para receber a configuração pública; o projeto não contém chave de serviço ou backend privilegiado.

## 1. Criar o projeto

1. Acesse o [console Firebase](https://console.firebase.google.com/), crie o projeto e anote seu **ID**, não apenas o nome de exibição.
2. Habilite Google Analytics e selecione/crie a propriedade GA4 e a região adequadas.
3. Confirme **Spark** no plano. Não vincule uma conta de faturamento, cartão ou plano Blaze.
4. Em Configurações do projeto → Integrações, confirme o vínculo com a propriedade Google Analytics.

Authentication (anônimo/e-mail), Firestore dentro das cotas, Remote Config dentro da cota Spark, Analytics e App Distribution atendem ao projeto. Não habilite Functions, Cloud Run ou Storage para este aplicativo. O [Remote Config possui cota gratuita no Spark](https://firebase.google.com/docs/remote-config/pricing); não configure loops de fetch. O app faz um fetch inicial, respeita intervalo mínimo e recebe publicações pelo listener em primeiro plano.

## 2. Authentication

No console, Build → Authentication → Começar → Método de login:

- Habilite **E-mail/senha**. Não é necessário link por e-mail.
- Habilite **Anônimo**.
- A conta administrativa informada para esta demonstração é **`usuario@gmail.com`**. Em Usuários, localize essa conta; se ainda não existir, crie-a em Adicionar usuário com a senha definida pelo responsável. A senha informada está em `docs/ACESSO_LOCAL.md`, arquivo local ignorado pelo Git. Não coloque a senha em `.env`, código ou documentos versionados.
- Copie o UID de `usuario@gmail.com` no Firebase Authentication para a autorização da próxima etapa.

O mobile chama `signInAnonymously()` apenas se não houver usuário persistido. Verifique a criação de um usuário anônimo na primeira execução e o mesmo UID após fechar e reabrir o app.

## 3. Firestore e primeiro administrador

1. Build → Firestore Database → Criar banco, edição Standard, banco `(default)`.
2. Escolha uma localização apropriada e comece com regras restritivas, não modo de teste público.
3. Na aba Dados, crie a coleção `admins`.
4. Crie o documento com **ID exatamente igual ao UID** da conta administrativa.
5. Adicione `nome` (string), por exemplo `Organização acadêmica`.

A existência de `admins/UID` autoriza essa conta. O navegador e o aplicativo não podem criar nem alterar documentos de administrador, mesmo se já estiverem autenticados. A atribuição inicial acontece apenas no console com sua permissão de proprietário/editor confiável.

### Publicar regras

Na raiz, depois de instalar as dependências:

```bash
npm install
npx firebase login
npx firebase projects:list
npx firebase use --add
# Escolha o projeto real, confira o ID e então publique:
npx firebase deploy --only firestore --project SEU_ID_REAL
```

O primeiro comando de deploy publica `firebase/firestore.rules` e `firebase/firestore.indexes.json`. Alternativamente, copie o arquivo de regras para a aba Regras do console e clique em Publicar. Confira o sucesso do deploy e a versão na aba Regras. O projeto não precisa de índices compostos; não desabilite os índices simples de `ativo` e `visitanteId`.

Não execute deploy genérico para publicar o exemplo Remote Config sobre um template que você já configurou. As alterações de missão para a avaliação devem ser feitas e publicadas pelo console.

### Modelo

```text
admins/{uid}                    nome: string (atribuição confiável pelo console)
estandes/{id}                   nome, descricao, localizacao: string
                                ativo: boolean
                                criadoEm, atualizadoEm: timestamp do servidor
checkins/{uid}_{estandeId}       visitanteId, estandeId: string
                                criadoEm: timestamp do servidor
```

Visitantes podem obter estandes individualmente (inclusive inativos), listar apenas a query `ativo == true` e ler apenas seus próprios check-ins. Administradores podem listar todos para contabilização. Visitas são imutáveis. A leitura pontual de uma visita própria ainda inexistente é permitida para a transação; nenhum visitante recebe acesso às visitas de outros.

## 4. Registrar Android

Configurações do projeto → Geral → Seus apps → Adicionar app Android:

- Pacote exato: **`circuito.descobertas`**.
- Nome: Circuito de Descobertas Android.
- Baixe o arquivo real **`google-services.json`**.
- Coloque em **`mobile/android/app/google-services.json`**, com esse nome exato.
- Confirme `project_id` no JSON e o package name. Não invente os campos.

O Gradle já declara o plugin Google Services e o aplica quando o JSON existe. A inicialização de produção usa `Firebase.initializeApp()` e os recursos Android gerados pelo plugin. Não é necessário adicionar dependências Firebase nativas manualmente: o FlutterFire faz isso.

### FlutterFire CLI

Com rede e acesso ao console, pode usar o fluxo oficial:

```bash
# Raiz: Firebase CLI instalada pelo npm install anterior
export PATH="$PWD/node_modules/.bin:$PATH"
dart pub global activate flutterfire_cli
export PATH="$HOME/.pub-cache/bin:$PATH"
cd mobile
flutterfire configure --project=SEU_ID_REAL --platforms=android \
  --android-package-name=circuito.descobertas
flutter pub get
```

Confira se a CLI salvou `android/app/google-services.json`; se não, faça o download no console. Ela também pode gerar `lib/firebase_options.dart`, que está ignorado pelo Git. Neste projeto Android, esse arquivo não precisa ser importado: a configuração vem dos recursos nativos. Não troque a inicialização para valores fictícios. Reinicie o build ao mudar JSON ou configuração nativa.

Fonte: [configuração FlutterFire](https://firebase.google.com/docs/flutter/setup) e [registro Android](https://firebase.google.com/docs/android/setup).

## 5. Registrar aplicação web

No **mesmo** projeto → Adicionar app Web → nome Circuito Admin. Hosting não é obrigatório para a demonstração local.

Copie os campos do objeto `firebaseConfig` fornecido pelo console para `admin-web/.env.local`:

```dotenv
VITE_FIREBASE_API_KEY=VALOR_PUBLICO_REAL
VITE_FIREBASE_AUTH_DOMAIN=DOMINIO_REAL
VITE_FIREBASE_PROJECT_ID=ID_REAL
VITE_FIREBASE_APP_ID=APP_ID_WEB_REAL
VITE_FIREBASE_MESSAGING_SENDER_ID=SENDER_ID_REAL
VITE_USE_EMULATORS=false
```

Os valores identificam o projeto e não concedem privilégio administrativo. As regras são a barreira de acesso. Não use senha do administrador, token de login ou chave privada nesse arquivo. Variáveis `VITE_` ficam disponíveis ao navegador.

Reinicie o Vite, faça login no painel com `usuario@gmail.com` e a senha disponível no registro local, e confirme o dashboard. Depois teste uma conta comum sem documento em `admins`: ela deve receber acesso negado. Para revogar um administrador, exclua seu documento pelo console; o listener do painel retira a autorização.

## 6. Criar dados fictícios reais

No painel autorizado, clique em **Carregar estandes de demonstração**. São criados no banco conectado:

| ID persistente | Nome | Localização |
|---|---|---|
| `robotica` | Laboratório de Robótica | Corredor A, Estande 01 |
| `amazonia` | Amazônia Sustentável | Corredor B, Estande 05 |
| `jogos` | Jogos Educativos | Corredor C, Estande 09 |

O procedimento é idempotente: não sobrescreve documentos existentes. Use a aba Dados do Firestore para conferir os três documentos e seus timestamps. O cadastro normal gera IDs automáticos; copie o ID exibido no payload do QR para o Remote Config quando usar outros estandes.

## 7. Remote Config e missão

Console Firebase → Run/Engage → Remote Config (a posição no menu pode variar) → Criar configuração:

| Parâmetro | Tipo | Valor inicial |
|---|---|---|
| `missao_ativa` | Boolean | `false` |
| `estandes_destaque` | String | `["robotica","amazonia"]` |

Use o valor padrão para todos, sem condições de público nesta demonstração. Publique a versão inicial. O arquivo `firebase/remote-config.example.json` é uma referência de template com missão desligada e lista vazia; os IDs da tabela acima só terão efeito depois de os estandes existirem.

Com o app em primeiro plano e conectado:

1. Confirme a lista normal, sem banner.
2. Altere `missao_ativa` para `true` e clique em **Publicar alterações**.
3. Aguarde o listener aplicar a atualização: banner e destaques devem aparecer no mesmo app aberto.
4. Toque em Abrir missão e confira apenas estandes existentes e ativos dos IDs selecionados.
5. Desative um participante pelo painel: ele deve sumir da lista e da missão.
6. Publique `missao_ativa = false`: o banner e os destaques devem desaparecer. Se a tela da missão estiver aberta, ela exibe que a missão terminou.

O serviço utiliza `onConfigUpdated.listen(...)`, `activate()`, padrões locais `false`/`[]` e encerramento da assinatura no dispose. JSON inválido resulta em lista de participantes vazia; a navegação normal permanece disponível. Não há timer de polling. O SDK mantém as atualizações em tempo real enquanto o aplicativo está em primeiro plano. Se houver erro de API, confira no Google Cloud do mesmo projeto se a Firebase Remote Config Realtime API está habilitada, sem ativar faturamento.

Fonte: [atualizações em tempo real do Remote Config para Flutter](https://firebase.google.com/docs/remote-config/flutter/real-time).

## 8. Analytics e GA4

Em Configurações do projeto → Integrações → Google Analytics, confira a propriedade vinculada e clique em abrir no Google Analytics. Anote o ID da propriedade e confira o fluxo Android do pacote correto.

Antes da gravação, na propriedade GA4:

1. Administrador → Exibição de dados → Definições personalizadas → Criar dimensão personalizada.
2. Nome: `Estande`;["robotica","amazonia"] escopo: **Evento**; parâmetro do evento: **`estande_id`**.
3. Salve com antecedência: dimensões e relatórios processados podem demorar para disponibilizar os valores. A dimensão não cria eventos retroativamente.
4. Abra Relatórios → Tempo real. Use o cartão de contagem de eventos por nome.
5. No app, abra efetivamente a missão: procure **`missao_aberta`**. A simples exibição do banner não gera esse evento.
6. Faça um check-in novo confirmado no Firestore: procure **`checkin_concluido`**.
7. Clique nesse evento no cartão de Tempo real para conferir os parâmetros e o valor de **`estande_id`**, por exemplo `robotica`. Use a visualização do usuário/dispositivo se necessário para identificar a interação recém-realizada.

Eventos podem levar alguns minutos para aparecer e a janela Tempo real é limitada; ensaie antes e grave a ação seguida do resultado real. Não use um UID, e-mail, nome de visitante ou senha como parâmetro. O aplicativo envia somente o identificador público do estande no evento de check-in.

### DebugView, apenas como diagnóstico

```bash
adb -s emulator-5554 shell setprop debug.firebase.analytics.app circuito.descobertas
adb -s emulator-5554 shell am force-stop circuito.descobertas
```

Reabra o app, vá ao DebugView do Firebase/GA4 e confira eventos e parâmetros. Uma visita duplicada não gera novo evento; use outro estande ou prepare uma identidade de teste antes do ensaio.

**Desligue o modo debug antes da evidência principal:**

```bash
adb -s emulator-5554 shell setprop debug.firebase.analytics.app .none.
adb -s emulator-5554 shell am force-stop circuito.descobertas
```

Reabra o APK distribuído e gere novas ações válidas. Eventos marcados como debug têm tratamento e cadência de upload próprios, e filtros de tráfego de desenvolvedores ativos podem excluí-los dos relatórios. Verifique Administrador → Filtros de dados. Não use apenas DebugView para alegar que os eventos apareceram no **relatório Tempo real** exigido pela avaliação.

Fontes: [DebugView e comandos Android](https://firebase.google.com/docs/analytics/debugview), [filtros de tráfego de desenvolvedores](https://support.google.com/analytics/answer/13296662).

## 9. Verificação final

Confirme o mesmo `projectId` nas duas aplicações, as regras publicadas, o administrador autorizado, os estandes no Firestore e os parâmetros publicados. Depois siga [TESTES.md](TESTES.md), [DISTRIBUICAO_APK.md](DISTRIBUICAO_APK.md) e o roteiro de vídeo. A execução local com Emulator Suite não verifica Remote Config, GA4 ou App Distribution.
