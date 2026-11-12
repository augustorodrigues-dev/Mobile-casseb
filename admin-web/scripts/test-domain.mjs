// Testes dos módulos TypeScript reais usando Node >= 24, sem rede ou dependências.
import { readFileSync } from 'node:fs';
import { stripTypeScriptTypes } from 'node:module';
import { test } from 'node:test';
import assert from 'node:assert/strict';
async function load(path) {
  const source=readFileSync(new URL(path,import.meta.url),'utf8');
  const code=stripTypeScriptTypes(source,{mode:'transform'});
  return import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);
}
const {dashboardStats,qrPayload}=await load('../src/services/stats.ts');
const {validateStand}=await load('../src/services/validation.ts');
const {errorMessage}=await load('../src/services/errors.ts');
const stand={id:'robotica',nome:'Robótica',descricao:'Robôs',localizacao:'A1',ativo:true};
test('dashboard totaliza registros reais e mantém visitas de inativos',()=>{
  assert.deepEqual(dashboardStats([stand,{...stand,id:'jogos',ativo:false}], [
    {estandeId:'robotica',visitanteId:'v1'}, {estandeId:'robotica',visitanteId:'v2'}, {estandeId:'jogos',visitanteId:'v1'},
  ]),{total:2,active:1,inactive:1,visits:3,byStand:{robotica:2,jogos:1}});
});
test('dashboard vazio não inventa visitas',()=>assert.equal(dashboardStats([],[]).visits,0));
test('QR tem o mesmo contrato do Flutter',()=>assert.equal(qrPayload('AbC-123'),'circuito://estande/AbC-123'));
for(const id of ['', '../x','x/y','id_com_underscore','robótica','a'.repeat(129),'id\n']) test(`rejeita ID ${JSON.stringify(id)}`,()=>assert.throws(()=>qrPayload(id)));
test('valida estande completo',()=>assert.equal(validateStand(stand),null));
for(const field of ['nome','descricao','localizacao']) test(`rejeita ${field} em branco`,()=>assert.ok(validateStand({...stand,[field]:'   '})));
for(const [field,max] of [['nome',100],['descricao',500],['localizacao',150]]) test(`limita ${field} a ${max}`,()=>assert.ok(validateStand({...stand,[field]:'a'.repeat(max+1)})));
test('credenciais inválidas têm mensagem clara',()=>assert.equal(errorMessage({code:'auth/invalid-credential'}),'E-mail ou senha incorretos.'));
test('permissão negada tem mensagem clara',()=>assert.match(errorMessage({code:'permission-denied'}),/Acesso negado/));
test('falta de rede tem mensagem clara',()=>assert.match(errorMessage({code:'unavailable'}),/Sem conexão/));
