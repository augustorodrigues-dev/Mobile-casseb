import { collection, doc, runTransaction, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';
import { db } from '../firebase/client';
import type { EstandeInput } from '../types';
import { validateStand } from './validation';
export async function saveStand(input: EstandeInput, id?: string): Promise<void> {
  const error = validateStand(input);
  if (error) throw new Error(error);
  if (!db) throw new Error('Firebase não configurado.');
  const data = { nome: input.nome.trim(), descricao: input.descricao.trim(), localizacao: input.localizacao.trim(), ativo: input.ativo, atualizadoEm: serverTimestamp() };
  if (id) await updateDoc(doc(db, 'estandes', id), data);
  else await setDoc(doc(collection(db, 'estandes')), { ...data, criadoEm: serverTimestamp() });
}
const examples: (EstandeInput & {id: string})[] = [
  {id:'robotica',nome:'Laboratório de Robótica',descricao:'Conheça robôs que transformam ideias em movimento e explore soluções criadas pelos alunos.',localizacao:'Corredor A, Estande 01',ativo:true},
  {id:'amazonia',nome:'Amazônia Sustentável',descricao:'Tecnologia e biodiversidade se encontram em projetos para o futuro da nossa região.',localizacao:'Corredor B, Estande 05',ativo:true},
  {id:'jogos',nome:'Jogos Educativos',descricao:'Aprenda jogando: experiências interativas que tornam o conhecimento uma descoberta.',localizacao:'Corredor C, Estande 09',ativo:true},
];
export async function seedStands(): Promise<void> {
  if (!db) throw new Error('Firebase não configurado.');
  const firestore = db;
  // Cria somente documentos ausentes, preservando edições e histórico.
  await runTransaction(firestore, async tx => {
    const refs = examples.map(e => doc(firestore, 'estandes', e.id));
    const snapshots = await Promise.all(refs.map(ref => tx.get(ref)));
    examples.forEach(({id: _id, ...data}, i) => {
      if (!snapshots[i].exists()) tx.set(refs[i], {...data, criadoEm: serverTimestamp(), atualizadoEm: serverTimestamp()});
    });
  });
}
