import { describe, expect, it } from 'vitest';
import { dashboardStats, qrPayload } from './stats';
import { validateStand } from './validation';
import { errorMessage } from './errors';
import type { Estande, Checkin } from '../types';
const stand:Estande = {id:'robotica',nome:'Robótica',descricao:'Robôs',localizacao:'A1',ativo:true};
describe('Dashboard e QR',()=>{
  it('contabiliza check-ins reais e preserva total de inativos',()=>{
    const data=dashboardStats([stand,{...stand,id:'jogos',ativo:false}], [
      {id:'a',visitanteId:'v1',estandeId:'robotica'}, {id:'b',visitanteId:'v2',estandeId:'robotica'},
      {id:'c',visitanteId:'v1',estandeId:'jogos'},
    ] as Checkin[]);
    expect(data).toEqual({total:2,active:1,inactive:1,visits:3,byStand:{robotica:2,jogos:1}});
  });
  it('estado vazio não inventa visitas',()=>expect(dashboardStats([],[]).visits).toBe(0));
  it('produz formato aceito pelo aplicativo',()=>expect(qrPayload('AbC-123')).toBe('circuito://estande/AbC-123'));
  it.each(['','../x','x/y','id_com_underscore','robótica','a'.repeat(129)])('rejeita ID %s',id=>expect(()=>qrPayload(id)).toThrow());
});
describe('Validação e erros',()=>{
  it('aceita estande completo',()=>expect(validateStand(stand)).toBeNull());
  it.each(['nome','descricao','localizacao'] as const)('rejeita %s em branco',field=>expect(validateStand({...stand,[field]:'   '})).not.toBeNull());
  it('limita comprimento',()=>expect(validateStand({...stand,nome:'a'.repeat(101)})).toContain('100'));
  it('informa credenciais incorretas sem expor cadastro de contas',()=>expect(errorMessage({code:'auth/invalid-credential'})).toBe('E-mail ou senha incorretos.'));
  it('informa indisponibilidade da rede',()=>expect(errorMessage({code:'unavailable'})).toContain('Sem conexão'));
});
