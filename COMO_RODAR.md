# Como rodar — guia rápido da equipe

Este guia é para quem recebeu o projeto pelo Drive. Todos usam o mesmo projeto Firebase, já configurado pelo responsável. Os outros integrantes não precisam criar outro projeto nem executar `firebase login` para usar o painel ou o aplicativo.

## Quem faz o quê

| Pessoa | Parte da demonstração | O que precisa |
|---|---|---|
| Responsável pelo Firebase | Console Firebase, App Distribution, Remote Config, Firestore, Authentication e GA4 | Acesso ao projeto e à propriedade GA4 |
| Integrante do painel | Cadastro de estande, geração do QR e contador de visitas | Node.js e navegador |
| Integrante do Android | Aceitar convite, instalar o APK, abrir missão e escanear QR | Celular Android ou emulador |

Cada integrante apresenta seu nome e narra sua parte. A sequência completa está no [roteiro do vídeo](docs/ROTEIRO_DEMONSTRACAO.md).

## 1. Receber e abrir o projeto

Baixe o ZIP do Drive, extraia e abra a pasta que contém este arquivo e o `README.md` no VS Code. Não execute os comandos dentro do ZIP.

O responsável deve incluir as configurações públicas do mesmo projeto: `admin-web/.env.local` e `mobile/android/app/google-services.json`. Se o `.env.local` não veio, copie `.env.example` para `.env.local` pelo explorador do VS Code; o exemplo desta cópia já contém a configuração web da demonstração. O pacote Android é `circuito.descobertas`.

Para preparar o ZIP, o responsável pode excluir `node_modules`, `build`, `.dart_tool`, `.gradle`, `.idea` e `mobile/android/local.properties`: cada computador recria esses arquivos. Deixe de fora o keystore (`*.jks`), `key.properties` e `docs/ACESSO_LOCAL.md`; eles não são necessários para executar o painel ou o mobile em debug. O `.gitignore` não exclui arquivos automaticamente de uma cópia pelo Drive. Envie a senha do painel separadamente aos integrantes.

## 2. Rodar o painel web

Instale Node.js **24.12 ou superior**. Abra um terminal na raiz da pasta extraída:

```bash
cd admin-web
npm ci
npm run dev
```

Abra no navegador o endereço mostrado no terminal, normalmente **http://127.0.0.1:5173**. Mantenha o terminal aberto.

Entre com o administrador **`usuario@gmail.com`** e a senha fornecida pelo responsável. Essa conta já deve estar autorizada em `admins/UID`; não é a conta Google de acesso ao console Firebase.

Os estandes existentes devem aparecer. Para o vídeo, cadastre um estande novo e ativo, por exemplo **Sensores da Floresta**, abra seu **QR Code** e baixe o PNG. O contador será atualizado quando o visitante concluir o check-in. Todos precisam estar conectados à internet; podem usar computadores e redes diferentes, desde que a configuração aponte para o mesmo Firebase.

Se aparecer “Vamos conectar o circuito”, confira `.env.local` e reinicie o terminal do Vite. Se aparecer acesso negado, o responsável confere a conta e `admins/UID`. Não execute `npm audit fix --force`; mantenha as versões do lockfile.

## 3. Usar o Android para o vídeo

O integrante visitante não precisa instalar Flutter se usar o APK distribuído:

1. Informe ao responsável o e-mail Google que usará como testador.
2. Abra o convite do **App Distribution**, aceite, acesse a versão e baixe o APK.
3. Autorize a instalação pelo navegador, se solicitado, instale e abra.
4. Mantenha esse mesmo aplicativo instalado durante a missão, o check-in e o Analytics.

A senha administrativa não é usada no Android. O visitante é autenticado anonimamente. A instalação e a abertura precisam aparecer na gravação. Instalar o APK debug enviado pelo Drive não comprova a instalação via App Distribution.

A versão release 1.0.0 já foi gerada e teve sua assinatura verificada. O responsável ainda precisa enviá-la ao App Distribution e convidar os testadores, seguindo [DISTRIBUICAO_APK.md](docs/DISTRIBUICAO_APK.md). O APK debug existente serve para desenvolvimento.

## 4. Opcional: executar o código Flutter

Somente quem for desenvolver ou executar pelo terminal precisa de **Flutter 3.47.9 / Dart 3.13.7**, Android SDK e um celular com depuração USB ou AVD aberto.

No Android Studio, abra o Device Manager e inicie um AVD. Em um novo terminal na raiz:

```bash
cd mobile
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Troque `emulator-5554` pelo ID real mostrado por `flutter devices`, inclusive se usar celular por USB. No Linux, pode preparar os caminhos executando `source scripts/android-env.sh` na raiz, antes de entrar em `mobile`. No Windows, use os atalhos abaixo depois de instalar o SDK pelo Android Studio.

### Atalhos para Windows

Na raiz do projeto, inicie o AVD pelo CMD ou PowerShell:

```powershell
.\scripts\start-android.bat
```

O nome padrão é `Small_Phone`. Se o seu AVD tiver outro nome, use `.\scripts\start-android.bat -AvdName "NomeDoSeuAVD"`. O script lista os nomes disponíveis se não encontrar o solicitado. O SDK é localizado pelas variáveis Android ou em `%LOCALAPPDATA%\Android\Sdk`. Para outro caminho, acrescente `-SdkPath "D:\Android\Sdk"`.

Em outro terminal **PowerShell**, na raiz, prepare o ambiente e rode o app:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\android-env.ps1
cd mobile
flutter pub get
flutter devices
flutter run -d emulator-5554
```

A política acima e as variáveis do script valem só para o terminal atual. Troque o ID pelo dispositivo listado. O Flutter precisa estar instalado e sua pasta `bin` deve estar no PATH. O `.bat` já aplica a política apenas ao processo que inicia o emulador.

Durante o desenvolvimento, `r` aplica hot reload e `q` encerra. Para a gravação principal, use a versão instalada pelo App Distribution, sem hot reload ou reinstalação entre as mudanças da missão.

## 5. Ler o QR

- **Celular físico:** abra o QR do painel no monitor e aponte o scanner do aplicativo para ele. Autorize a câmera.
- **Emulador:** a câmera traseira precisa ser **VirtualScene**. Em `… → Camera → Virtual scene images`, importe o PNG em **Wall**. No scanner, segure Alt para olhar ao redor e use W/A/S/D para se aproximar. O QR é um cartaz na sala, não a imagem da TV. Partindo da TV, gire aproximadamente meia-volta e ajuste a posição lateral para contornar a coluna.

Aguarde **Descoberta registrada!**, confira o indicador **Visitado** e o aumento do contador no painel. No vídeo, faça essa leitura depois que o responsável publicar a missão e o visitante abrir a tela da missão.

Para gerar um novo check-in, escolha um estande ainda não visitado. Repetir um QR já usado com o mesmo visitante deve informar duplicidade e não gera um novo evento de conclusão.

## Se precisar de mais detalhes

Consulte [INSTALACAO.md](docs/INSTALACAO.md) para ambiente e erros, [TESTES.md](docs/TESTES.md) para resultados e [ROTEIRO_DEMONSTRACAO.md](docs/ROTEIRO_DEMONSTRACAO.md) para a ordem da gravação. Questões do console Firebase e do GA4 ficam com o responsável.
