import { act } from 'react';
import { createRoot, type Root } from 'react-dom/client';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { StandForm } from './StandForm';
import { saveStand } from '../services/estandes';
vi.mock('../services/estandes',()=>({saveStand:vi.fn()}));
let root:Root;let container:HTMLDivElement;
beforeEach(()=>{vi.mocked(saveStand).mockReset();container=document.createElement('div');document.body.append(container);root=createRoot(container);});
afterEach(async()=>{await act(()=>root.unmount());container.remove();});
async function type(label:string,value:string){
  const input=Array.from(container.querySelectorAll('label')).find(el=>el.textContent===label)?.querySelector('input,textarea') as HTMLInputElement|HTMLTextAreaElement;
  const prototype=input.tagName==='TEXTAREA'?HTMLTextAreaElement.prototype:HTMLInputElement.prototype;
  await act(async()=>{Object.getOwnPropertyDescriptor(prototype,'value')!.set!.call(input,value);input.dispatchEvent(new Event('input',{bubbles:true}));});
}
async function submit(){await act(async()=>{container.querySelector('form')!.dispatchEvent(new Event('submit',{bubbles:true,cancelable:true}));});}
describe('Cadastro e edição',()=>{
  it('salva campos preenchidos e confirma sucesso',async()=>{
    vi.mocked(saveStand).mockResolvedValue();const saved=vi.fn();
    await act(()=>root.render(<StandForm onClose={vi.fn()} onSaved={saved}/>));
    await type('Nome','Robótica');await type('Descrição breve','Robôs para aprender');await type('Localização','Corredor A');await submit();
    expect(saved).toHaveBeenCalledOnce();
    expect(saveStand).toHaveBeenCalledWith({nome:'Robótica',descricao:'Robôs para aprender',localizacao:'Corredor A',ativo:true},undefined);
  });
  it('rejeita espaços e não grava cadastro vazio',async()=>{
    await act(()=>root.render(<StandForm onClose={vi.fn()} onSaved={vi.fn()}/>));
    for(const label of ['Nome','Descrição breve','Localização']) await type(label,'   ');
    await submit();expect(container.querySelector('[role=alert]')?.textContent).toContain('Preencha o campo nome');expect(saveStand).not.toHaveBeenCalled();
  });
  it('mantém formulário quando Firebase nega a gravação',async()=>{
    vi.mocked(saveStand).mockRejectedValue({code:'permission-denied'});const saved=vi.fn();
    await act(()=>root.render(<StandForm stand={{id:'robotica',nome:'Robótica',descricao:'Robôs',localizacao:'A1',ativo:true}} onClose={vi.fn()} onSaved={saved}/>));
    await submit();expect(container.querySelector('[role=alert]')?.textContent).toContain('Acesso negado');expect(saved).not.toHaveBeenCalled();
  });
});
