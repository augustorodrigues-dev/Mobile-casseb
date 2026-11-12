// Apenas localhost e projeto demo: este script nunca inicializa dados em produção.
const project = 'demo-circuito';
const authBase = 'http://127.0.0.1:9099';
const firestoreBase = `http://127.0.0.1:8080/v1/projects/${project}/databases/(default)/documents`;
const email = 'admin@circuito.test';
const password = 'Circuito-local-2026!';
async function request(url, options) {
  const response = await fetch(url, options);
  const body = await response.json();
  if (!response.ok) throw new Error(JSON.stringify(body));
  return body;
}
let user;
try {
  user = await request(`${authBase}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`, {
    method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({email, password, returnSecureToken: true}),
  });
} catch {
  user = await request(`${authBase}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=demo-key`, {
    method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({email, password, returnSecureToken: true}),
  });
}
await request(`${firestoreBase}/admins/${user.localId}`, {
  method: 'PATCH', headers: {'Authorization': 'Bearer owner', 'Content-Type': 'application/json'},
  body: JSON.stringify({fields: {nome: {stringValue: 'Organização (local)'}}}),
});
console.log(`Administrador LOCAL criado: ${email} / ${password}`);
console.log('Abra o painel com VITE_USE_EMULATORS=true e use “Carregar estandes de demonstração”.');
