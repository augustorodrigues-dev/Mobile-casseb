import { readFileSync } from 'node:fs';
import { before, after, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, query, runTransaction, serverTimestamp, setDoc, Timestamp, updateDoc, where } from 'firebase/firestore';
let env;
const stand = (ativo=true) => ({nome:'Robótica',descricao:'Projeto fictício',localizacao:'A1',ativo,criadoEm:serverTimestamp(),atualizadoEm:serverTimestamp()});
const visit = (uid='visitor',id='robotica') => ({visitanteId:uid,estandeId:id,criadoEm:serverTimestamp()});
const visitor = () => env.authenticatedContext('visitor', {firebase:{sign_in_provider:'anonymous'}}).firestore();
const admin = () => env.authenticatedContext('admin').firestore();
before(async()=>{
  env = await initializeTestEnvironment({projectId:'demo-circuito',firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firebase/firestore.rules','utf8')}});
});
after(async()=>{await env?.cleanup();});
beforeEach(async()=>{
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async context=>{
    const db=context.firestore();
    await setDoc(doc(db,'admins','admin'),{nome:'Organização'});
    await setDoc(doc(db,'estandes','robotica'),stand());
    await setDoc(doc(db,'estandes','inativo'),stand(false));
  });
});
test('sem autenticação não lê nem cadastra estandes',async()=>{
  const db=env.unauthenticatedContext().firestore();
  await assertFails(getDocs(query(collection(db,'estandes'),where('ativo','==',true))));
  await assertFails(getDoc(doc(db,'estandes','robotica')));
  await assertFails(setDoc(doc(db,'estandes','outro'),stand()));
});
test('administrador consulta e cadastra estandes',async()=>{
  const db=admin();await assertSucceeds(getDocs(collection(db,'estandes')));
  await assertSucceeds(setDoc(doc(db,'estandes','novo'),stand()));
  await assertSucceeds(updateDoc(doc(db,'estandes','novo'),{ativo:false,atualizadoEm:serverTimestamp()}));
});
test('autenticação comum não concede privilégios administrativos',async()=>{
  const db=env.authenticatedContext('email-user',{email:'comum@example.test'}).firestore();
  await assertFails(setDoc(doc(db,'estandes','novo'),stand()));
  await assertFails(updateDoc(doc(db,'estandes','robotica'),{nome:'Alterado',atualizadoEm:serverTimestamp()}));
});
test('visitante só lista consulta com ativo=true e pode obter inativo pelo ID',async()=>{
  const db=visitor();const result=await assertSucceeds(getDocs(query(collection(db,'estandes'),where('ativo','==',true))));
  assert.equal(result.size,1);
  await assertFails(getDocs(collection(db,'estandes')));
  await assertSucceeds(getDoc(doc(db,'estandes','inativo')));
  await assertSucceeds(getDoc(doc(db,'estandes','inexistente')));
});
test('ninguém pode atribuir privilégios pelo SDK cliente',async()=>{
  await assertFails(setDoc(doc(visitor(),'admins','visitor'),{nome:'Admin'}));
  await assertFails(setDoc(doc(admin(),'admins','novo'),{nome:'Admin'}));
  await assertSucceeds(getDoc(doc(visitor(),'admins','visitor')));
  await assertFails(getDoc(doc(visitor(),'admins','admin')));
});
for(const [label,change] of [
  ['campo extra',{extra:true}],['nome vazio',{nome:''}],['apenas espaços',{nome:'   '}],
  ['nome longo',{nome:'a'.repeat(101)}],['tipo incorreto',{ativo:'sim'}],
  ['data arbitrária',{criadoEm:Timestamp.fromMillis(0)}],['descrição ausente',{descricao:null}],
]) test(`admin também deve respeitar validação: ${label}`,async()=>{
  await assertFails(setDoc(doc(admin(),'estandes','novo'),{...stand(),...change}));
});
test('descrição pode conter várias linhas e criadoEm é imutável',async()=>{
  const db=admin();await assertSucceeds(setDoc(doc(db,'estandes','novo'),{...stand(),descricao:'Linha 1\nLinha 2'}));
  await assertFails(updateDoc(doc(db,'estandes','novo'),{criadoEm:Timestamp.fromMillis(0),atualizadoEm:serverTimestamp()}));
  await assertFails(deleteDoc(doc(db,'estandes','novo')));
});
test('leitura própria inexistente permite iniciar transação',async()=>{
  await assertSucceeds(getDoc(doc(visitor(),'checkins','visitor_robotica')));
  await assertFails(getDoc(doc(visitor(),'checkins','outro_robotica')));
});
test('cria check-in próprio; rejeita sobrescrita, edição e exclusão',async()=>{
  const ref=doc(visitor(),'checkins','visitor_robotica');
  await assertSucceeds(setDoc(ref,visit()));
  await assertFails(setDoc(ref,visit()));await assertFails(updateDoc(ref,{criadoEm:serverTimestamp()}));
  await assertFails(deleteDoc(ref));
  await assertSucceeds(getDocs(collection(admin(),'checkins')));
});
test('check-in exige UID próprio, ID determinístico, campos exatos e timestamp do servidor',async()=>{
  const db=visitor();
  await assertFails(setDoc(doc(db,'checkins','outro_robotica'),visit('outro')));
  await assertFails(setDoc(doc(db,'checkins','aleatorio'),visit()));
  await assertFails(setDoc(doc(db,'checkins','visitor_robotica'),{...visit(),extra:true}));
  await assertFails(setDoc(doc(db,'checkins','visitor_robotica'),{...visit(),criadoEm:Timestamp.fromMillis(0)}));
  await assertFails(setDoc(doc(db,'checkins','visitor_robotica'),{visitanteId:'visitor',estandeId:'robotica'}));
});
test('estande ausente ou inativo não aceita visita',async()=>{
  for(const id of ['inativo','inexistente']) await assertFails(setDoc(doc(visitor(),'checkins',`visitor_${id}`),visit('visitor',id)));
});
test('consultas de check-in isolam visitantes',async()=>{
  await assertSucceeds(setDoc(doc(visitor(),'checkins','visitor_robotica'),visit()));
  const other=env.authenticatedContext('other').firestore();
  await assertFails(getDoc(doc(other,'checkins','visitor_robotica')));
  await assertFails(getDocs(collection(other,'checkins')));
  const own=await assertSucceeds(getDocs(query(collection(visitor(),'checkins'),where('visitanteId','==','visitor'))));
  assert.equal(own.size,1);
});
test('desativar estande preserva check-ins históricos',async()=>{
  await assertSucceeds(setDoc(doc(visitor(),'checkins','visitor_robotica'),visit()));
  await assertSucceeds(updateDoc(doc(admin(),'estandes','robotica'),{ativo:false,atualizadoEm:serverTimestamp()}));
  assert.equal((await getDocs(collection(admin(),'checkins'))).size,1);
  await assertFails(setDoc(doc(env.authenticatedContext('other').firestore(),'checkins','other_robotica'),visit('other')));
});
test('duas gravações concorrentes criam apenas um documento',async()=>{
  const db1=visitor();const db2=env.authenticatedContext('visitor').firestore();
  const results=await Promise.allSettled([
    setDoc(doc(db1,'checkins','visitor_robotica'),visit()),
    setDoc(doc(db2,'checkins','visitor_robotica'),visit()),
  ]);
  assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
  assert.equal((await getDocs(collection(admin(),'checkins'))).size,1);
});
test('transação com conflito só confirma uma visita e identifica duplicidade',async()=>{
  async function checkin(db) {
    return runTransaction(db,async tx=>{
      const standDoc=await tx.get(doc(db,'estandes','robotica'));
      assert.equal(standDoc.data().ativo,true);
      const ref=doc(db,'checkins','visitor_robotica');
      if((await tx.get(ref)).exists()) throw new Error('duplicado');
      tx.set(ref,visit());return 'criado';
    });
  }
  const results=await Promise.allSettled([checkin(visitor()),checkin(env.authenticatedContext('visitor').firestore())]);
  assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
  assert.equal((await getDocs(collection(admin(),'checkins'))).size,1);
});
