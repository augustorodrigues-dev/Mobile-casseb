export function errorMessage(error: unknown): string {
  const code = error && typeof error === 'object' && 'code' in error ? String(error.code) : '';
  if (['auth/invalid-credential','auth/invalid-login-credentials','auth/user-not-found','auth/wrong-password'].includes(code)) return 'E-mail ou senha incorretos.';
  if (code === 'auth/too-many-requests') return 'Muitas tentativas. Aguarde alguns minutos.';
  if (code === 'auth/invalid-email') return 'Informe um e-mail válido.';
  if (code === 'auth/user-disabled') return 'Esta conta foi desativada.';
  if (code === 'permission-denied') return 'Acesso negado. Verifique a autorização administrativa e as regras do Firestore.';
  if (code === 'unavailable' || code === 'auth/network-request-failed') return 'Sem conexão com o Firebase. Verifique a internet e tente novamente.';
  return 'Não foi possível concluir a operação. Tente novamente e confira a configuração do Firebase.';
}
