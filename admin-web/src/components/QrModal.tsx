import { useEffect, useState } from 'react';
import QRCode from 'qrcode';
import { Download, Printer } from '../ui/icons';
import type { Estande } from '../types';
import { qrPayload } from '../services/stats';
import { Modal } from './Modal';
export function QrModal({stand,onClose}:{stand:Estande;onClose:()=>void}) {
  const [png,setPng]=useState('');const [error,setError]=useState('');
  const payload=qrPayload(stand.id);
  useEffect(()=>{let alive=true;QRCode.toDataURL(payload,{width:1024,margin:4,errorCorrectionLevel:'M'}).then(url=>{if(alive)setPng(url);}).catch(()=>{if(alive)setError('Não foi possível gerar o QR Code. Feche e tente novamente.');});return()=>{alive=false;};},[payload]);
  return <Modal title="QR Code do estande" onClose={onClose}><div className="print-sheet"><span className="eyebrow">AMAZON HACKING · CIRCUITO DE DESCOBERTAS</span><h3>{stand.nome}</h3><p>{stand.localizacao}</p>{png?<img className="qr" src={png} alt={`QR Code para check-in em ${stand.nome}`}/>:<p role="status">Gerando QR Code…</p>}<p>Aponte a câmera do aplicativo e registre sua descoberta.</p><code>{payload}</code>{!stand.ativo && <p className="notice error">Estande inativo: novos check-ins estão bloqueados.</p>}</div>{error && <p role="alert">{error}</p>}<div className="form-actions no-print">{png && <a className="button" href={png} download={`circuito-${stand.id}.png`}><Download size={16}/>Baixar PNG</a>}<button className="secondary" disabled={!png} onClick={()=>window.print()}><Printer size={16}/>Imprimir</button></div></Modal>;
}
