import { existsSync, readFileSync, mkdirSync, copyFileSync, chmodSync } from 'node:fs';
import { dirname, resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const arquivos = [
  'admin-web/.env.local',
  'mobile/android/app/google-services.json',
  'mobile/lib/firebase_options.dart',
  'mobile/android/key.properties',
  'mobile/android/app/circuito-release.jks',
  'docs/ACESSO_LOCAL.md',
];

export function restaurar(origem, destino, sobrescrever = false) {
  // Confira o pacote inteiro antes de modificar a configuração existente.
  for (const arquivo of arquivos) {
    const fonte = join(origem, arquivo);
    const alvo = join(destino, arquivo);
    if (!existsSync(fonte)) throw new Error(`Arquivo ausente no pacote: ${arquivo}`);
    if (existsSync(alvo) && !readFileSync(fonte).equals(readFileSync(alvo)) && !sobrescrever) {
      throw new Error(`Já existe uma configuração diferente em ${arquivo}. Faça backup e use --sobrescrever se desejar substituí-la.`);
    }
  }
  for (const arquivo of arquivos) {
    const alvo = join(destino, arquivo);
    mkdirSync(dirname(alvo), { recursive: true });
    copyFileSync(join(origem, arquivo), alvo);
    if (process.platform !== 'win32') chmodSync(alvo, 0o600);
  }
  return arquivos.length;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const argumentos = process.argv.slice(2);
    if (argumentos.some(arg => arg.startsWith('--') && arg !== '--sobrescrever') || argumentos.filter(arg => !arg.startsWith('--')).length > 1) {
      throw new Error('Uso: node scripts/restaurar-arquivos-locais.mjs [pasta-do-pacote] [--sobrescrever]');
    }
    const raiz = resolve(dirname(fileURLToPath(import.meta.url)), '..');
    const pasta = argumentos.find(arg => !arg.startsWith('--'));
    const quantidade = restaurar(pasta ? resolve(pasta) : join(raiz, 'arquivos-locais'), raiz, argumentos.includes('--sobrescrever'));
    console.log(`${quantidade} arquivos restaurados. Agora instale as dependências conforme o README.`);
    console.log('O Android SDK deve ser configurado nesta máquina; local.properties não é compartilhado.');
  } catch (erro) {
    console.error(`Não foi possível restaurar: ${erro.message}`);
    process.exitCode = 1;
  }
}
