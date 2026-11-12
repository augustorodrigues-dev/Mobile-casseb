import type { Checkin, Estande } from '../types';
export function dashboardStats(stands: Estande[], checkins: Checkin[]) {
  const byStand = checkins.reduce<Record<string, number>>((counts, visit) => {
    counts[visit.estandeId] = (counts[visit.estandeId] ?? 0) + 1;
    return counts;
  }, {});
  const active = stands.filter(s => s.ativo).length;
  return { total: stands.length, active, inactive: stands.length - active, visits: checkins.length, byStand };
}
export function qrPayload(id: string) {
  if (!/^[A-Za-z0-9-]{1,128}$/.test(id)) throw new Error('Identificador de estande inválido.');
  return `circuito://estande/${id}`;
}
