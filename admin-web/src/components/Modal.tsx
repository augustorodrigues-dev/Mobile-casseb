import { useEffect, useRef, type ReactNode } from 'react';
import { X } from '../ui/icons';
export function Modal({title,onClose,children}: {title:string;onClose:()=>void;children:ReactNode}) {
  const ref = useRef<HTMLDialogElement>(null);
  useEffect(()=>{ const dialog = ref.current; if(dialog && !dialog.open) dialog.showModal(); return ()=>dialog?.close(); },[]);
  return <dialog ref={ref} className="modal" aria-label={title} onCancel={e=>{e.preventDefault();onClose();}}><div className="modal-heading"><h2>{title}</h2><button className="icon-button" aria-label="Fechar" onClick={onClose}><X size={20}/></button></div>{children}</dialog>;
}
