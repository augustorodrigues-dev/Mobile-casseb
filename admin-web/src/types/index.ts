import type { Timestamp } from 'firebase/firestore';
export interface Estande { id: string; nome: string; descricao: string; localizacao: string; ativo: boolean; criadoEm?: Timestamp; atualizadoEm?: Timestamp }
export type EstandeInput = Pick<Estande, 'nome' | 'descricao' | 'localizacao' | 'ativo'>;
export interface Checkin { id: string; visitanteId: string; estandeId: string; criadoEm?: Timestamp }
