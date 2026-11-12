import { useState, type FormEvent } from 'react';
import type { Estande, EstandeInput } from '../types';
import { saveStand } from '../services/estandes';
import { validateStand } from '../services/validation';
import { errorMessage } from '../services/errors';
import { Modal } from './Modal';
export function StandForm({stand,onClose,onSaved}:{stand?:Estande;onClose:()=>void;onSaved:()=>void}) {
  const [input,setInput] = useState<EstandeInput>(stand ?? {nome:'',descricao:'',localizacao:'',ativo:true});
  const [error,setError] = useState('');const [busy,setBusy] = useState(false);
  async function submit(e:FormEvent) {
    e.preventDefault(); const invalid=validateStand(input); if(invalid){setError(invalid);return;}
    setBusy(true);setError('');
    try {await saveStand(input,stand?.id);onSaved();} catch(error){setError(errorMessage(error));} finally {setBusy(false);}
  }
  return <Modal title={stand?'Editar estande':'Novo estande'} onClose={()=>{if(!busy)onClose();}}><form onSubmit={submit} className="form-stack">
    <p className="muted">Uma nova oportunidade de descobrir algo incrível.</p>
    <label>Nome<input autoFocus value={input.nome} maxLength={100} required onChange={e=>setInput({...input,nome:e.target.value})} placeholder="Ex.: Laboratório de Robótica"/></label>
    <label>Descrição breve<textarea value={input.descricao} maxLength={500} required rows={3} onChange={e=>setInput({...input,descricao:e.target.value})}/></label>
    <label>Localização<input value={input.localizacao} maxLength={150} required onChange={e=>setInput({...input,localizacao:e.target.value})} placeholder="Corredor A, Estande 01"/></label>
    <label className="checkbox"><input type="checkbox" checked={input.ativo} onChange={e=>setInput({...input,ativo:e.target.checked})}/>Disponível para visitação</label>
    {error && <p role="alert" className="notice error">{error}</p>}
    <div className="form-actions"><button type="button" className="secondary" disabled={busy} onClick={onClose}>Cancelar</button><button disabled={busy}>{busy?'Salvando…':'Salvar estande'}</button></div>
  </form></Modal>;
}
