import type { EstandeInput } from '../types';
export function validateStand(input: EstandeInput): string | null {
  const fields = [[input.nome,100,'nome'],[input.descricao,500,'descrição'],[input.localizacao,150,'localização']] as const;
  for (const [value, max, label] of fields) {
    if (!value.trim()) return `Preencha o campo ${label}.`;
    if (value.trim().length > max) return `O campo ${label} deve ter até ${max} caracteres.`;
  }
  return null;
}
