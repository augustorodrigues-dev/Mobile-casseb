import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { arquivos, restaurar } from './restaurar-arquivos-locais.mjs';

test('restaura pacote, permite repetição e protege configurações existentes', () => {
  const temp = mkdtempSync(join(tmpdir(), 'circuito-config-'));
  try {
    const origem = join(temp, 'pacote com espaços');
    const destino = join(temp, 'projeto');
    for (const arquivo of arquivos) {
      const fonte = join(origem, arquivo);
      mkdirSync(dirname(fonte), { recursive: true });
      writeFileSync(fonte, `teste:${arquivo}`);
    }
    assert.equal(restaurar(origem, destino), 6);
    for (const arquivo of arquivos) assert.equal(readFileSync(join(destino, arquivo), 'utf8'), `teste:${arquivo}`);
    assert.equal(restaurar(origem, destino), 6);
    writeFileSync(join(destino, arquivos[0]), 'configuração própria');
    assert.throws(() => restaurar(origem, destino), /configuração diferente/);
    assert.equal(readFileSync(join(destino, arquivos[0]), 'utf8'), 'configuração própria');
    assert.equal(restaurar(origem, destino, true), 6);
    rmSync(join(origem, arquivos.at(-1)));
    writeFileSync(join(destino, arquivos[0]), 'preservar');
    assert.throws(() => restaurar(origem, destino, true), /Arquivo ausente/);
    assert.equal(readFileSync(join(destino, arquivos[0]), 'utf8'), 'preservar');
  } finally {
    rmSync(temp, { recursive: true, force: true });
  }
});
