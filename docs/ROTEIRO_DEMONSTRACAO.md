# Roteiro — três vídeos independentes

Cada integrante grava sozinho, no seu horário, com sua própria tela e narração. Nenhum trecho exige outra pessoa operando o sistema, aguardando um sinal ou gravando simultaneamente. Cada um diz seu nome no começo. Somente o responsável pelo Firebase acessa os consoles Firebase e GA4.

Os três arquivos podem ser unidos em blocos completos: painel → Android → Firebase. Conforme a exigência da atividade, cada integrante envia individualmente a demonstração completa com a participação identificável dos três; não presumam que enviar apenas seu trecho isolado atende à entrega.

## Preparação comum

- Todos usam o mesmo projeto Firebase, com internet, e dados fictícios.
- APK release assinado distribuído pelo App Distribution; testadores convidados previamente. Veja [DISTRIBUICAO_APK.md](DISTRIBUICAO_APK.md).
- Execução do projeto: [COMO_RODAR.md](../COMO_RODAR.md).
- Cada pessoa que testar um check-in usa um estande ainda não visitado pelo seu visitante. Uma visita duplicada não gera outro evento.
- Não mostrem senhas, chaves privadas ou tokens.
- Os blocos são demonstrações separadas do mesmo sistema; não apresentem as ações de sessões diferentes como uma única sequência ao vivo.

## Vídeo 1 — integrante do painel web

**Grava sozinho apenas o painel, no navegador. Não depende de check-in feito por outra pessoa.**

Fala inicial: “Sou [nome] e vou mostrar o painel administrativo do Circuito de Descobertas, um sistema para incentivar a circulação pelos estandes do Amazon Hacking.”

1. Mostre o painel autenticado e explique que o administrador usa Firebase Authentication com autorização administrativa.
2. Cadastre um estande ativo com dados fictícios, por exemplo “Sensores da Floresta”, descrição “Monitoramento ambiental com sensores” e localização “Corredor D, Estande 12”.
3. Mostre a confirmação e o estande na lista. Explique que os dados são armazenados no Cloud Firestore.
4. Edite uma informação e mostre o resultado salvo.
5. Abra o QR Code e baixe o PNG, mostrando o nome do estande e seu identificador.
6. Mostre os indicadores do dashboard e os totais reais já registrados. Não diga que ocorreu um novo check-in durante esse vídeo se isso não aconteceu.
7. Encerre sua apresentação.

A atualização do contador após uma nova visita será demonstrada pelo responsável pelo Firebase, sozinho, no vídeo 3.

## Vídeo 2 — integrante do Android

**Grava sozinho seu dispositivo Android. Não precisa que ninguém altere a missão durante seu vídeo.**

Fala inicial: “Sou [nome] e vou mostrar a instalação e o uso do aplicativo Android como visitante.”

1. Abra o convite do App Distribution na conta Google convidada e acesse a versão disponibilizada.
2. Grave o download, a instalação e a abertura do aplicativo. Mostre o processo real; instalação manual de APK do Drive e `flutter run` não substituem essa evidência.
3. Explique que o visitante recebe uma identidade anônima pelo Firebase Authentication, sem preencher cadastro.
4. Mostre a lista e abra os detalhes de um estande ativo. Se usar o estande do vídeo 1, confirme seu nome e localização; ele precisa já estar cadastrado antes desta gravação.
5. Use um QR PNG previamente baixado do painel para um estande ainda não visitado. Abra o scanner e leia pela câmera.
6. Mostre a confirmação e o indicador Visitado. Explique que a visita foi registrada no Firestore.
7. Leia novamente o mesmo QR e mostre a mensagem de visita já registrada.
8. Encerre. Não é necessário ativar ou desativar a missão nesta parte.

No celular, aponte a câmera para o QR em outro monitor. No emulador, configure câmera traseira VirtualScene e importe o PNG em Wall; enquadre o cartaz na sala, não a TV. Prepare a imagem antes de gravar.

## Vídeo 3 — você: Firebase, missão e Analytics

**Você grava sozinho. Usa seu próprio celular ou emulador e seu próprio navegador com painel, Firebase e GA4. Não precisa da presença ou da gravação dos colegas.**

Para mostrar o app e os consoles na sua gravação, use um emulador no seu computador ou grave/espelhe seu próprio celular. O app deve ser o APK instalado pelo App Distribution, sem executar `flutter run` para a evidência principal.

Fala inicial: “Sou [nome] e vou demonstrar os serviços Firebase e o fluxo integrado da missão surpresa.”

### 1. Distribuição e autenticação

- Mostre a evidência real de assinatura do APK release, conforme [DISTRIBUICAO_APK.md](DISTRIBUICAO_APK.md).
- No App Distribution, mostre a versão disponibilizada e os testadores convidados.
- Identifique o Firebase Authentication e seus provedores: e-mail/senha para administrador e anônimo para visitante. Só associe um UID a um dispositivo específico se conseguir verificá-lo.

### 2. Cadastro e QR para sua própria demonstração

1. No seu navegador, abra o painel e cadastre outro estande fictício novo e ativo. Isso garante que seu visitante ainda não o tenha visitado.
2. Mostre esse estande aparecendo no seu app instalado.
3. Abra o QR no painel e prepare sua leitura pela câmera. Copie o ID real para configurar a missão.
4. Mostre o total inicial do estande e seu documento no Cloud Firestore.

### 3. Remote Config e visita, tudo operado por você

1. Publique `missao_ativa=false` e mostre o app na lista normal, sem banner.
2. No Remote Config, configure `estandes_destaque` como string JSON contendo o ID verdadeiro do seu novo estande:

   ```json
   ["ID_REAL_DO_SEU_ESTANDE"]
   ```

   Substitua o marcador pelo ID real.
3. Altere `missao_ativa` para `true` e grave a publicação.
4. Volte ao seu app já aberto e mostre banner e destaque aparecendo, sem reinstalar ou recompilar.
5. Abra a missão. Explique que essa ação envia `missao_aberta` ao Firebase Analytics.
6. Abra o scanner e leia o QR pela câmera. Mostre a confirmação. Explique que, após a gravação real, o app envia `checkin_concluido` com `estande_id`.
7. Volte ao painel e mostre o total atualizado automaticamente, comparando com o valor inicial. Mantenha o painel aberto durante o fluxo, sem recarregar.
8. No Firestore, mostre o documento da visita em `checkins`, incluindo `estandeId` e `criadoEm`.
9. No Remote Config, publique `missao_ativa=false`.
10. Volte ao mesmo app e mostre o banner desaparecendo e a lista normal funcionando, com a visita preservada.

Você mesmo alterna entre suas janelas e seu app. Não há troca de apresentador nem participação dos colegas. Não reinstale, não limpe dados nem faça hot reload entre ativação e desativação.

### 4. GA4 Tempo real

Use o APK distribuído como visitante comum, com Analytics debug desligado. Caso seu dispositivo tenha usado modo debug, antes da demonstração execute:

```bash
adb -s ID_DO_DISPOSITIVO shell setprop debug.firebase.analytics.app .none.
adb -s ID_DO_DISPOSITIVO shell am force-stop circuito.descobertas
```

Substitua pelo ID de `adb devices` e reabra o app antes de gerar os eventos. Prepare antecipadamente a propriedade GA4 vinculada ao projeto e a dimensão personalizada de escopo de evento `estande_id`, quando necessária.

1. Abra **Relatórios → Tempo real** no GA4.
2. No cartão de contagem por nome do evento, mostre **`missao_aberta`** e **`checkin_concluido`** gerados na sua demonstração.
3. Abra **`checkin_concluido`** e mostre o valor do parâmetro **`estande_id`**, correspondente ao estande visitado.
4. Se os eventos demorarem, pause apenas sua própria gravação e retome quando aparecerem. Isso não depende dos colegas. DebugView ou logs não substituem o relatório Tempo real.
5. Se os eventos saírem da janela do relatório, gere novas ações válidas com missão ativa e outro estande ainda não visitado; repita também a desativação.

Encerre resumindo os serviços e o resultado observado.

## Conferência dos 3,5 pontos

| Critério | Evidência |
|---|---|
| App Distribution — 1,0 | Vídeo 2: acesso, instalação e abertura; vídeo 3: assinatura, release e convite |
| Remote Config — 1,0 | Vídeo 3: missão desligada, publicação da ativação, app com destaques, publicação da desativação e retorno no mesmo APK |
| Analytics — 1,0 | Vídeo 3: ações próprias como visitante comum e GA4 Tempo real com os dois eventos e o valor de `estande_id` |
| Integração — 0,5 | Vídeos 1 e 2: painel e Android; vídeo 3: fluxo completo de cadastro, app, QR, check-in, Firestore e contador |
| Participação dos três | Cada um se apresenta e narra seu próprio vídeo; os três blocos compõem a demonstração final |

Só considere cada evidência concluída depois de executar e registrar a ação e seu resultado real.
