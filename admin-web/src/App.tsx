import { useState } from 'react';
import { signOut } from 'firebase/auth';
import { Compass } from './ui/icons';
import { auth, configured } from './firebase/client';
import { useAdmin } from './hooks/useAdmin';
import { errorMessage } from './services/errors';
import { Dashboard } from './pages/Dashboard';
import { Login } from './pages/Login';
export default function App() {
  const state=useAdmin();const [logoutError,setLogoutError]=useState('');
  if (!configured) return <main className="setup"><Compass size={54}/><h1>Vamos conectar o circuito.</h1><p>Configure as variáveis públicas do Firebase em <code>admin-web/.env.local</code> e reinicie o Vite.</p><p>O passo a passo está em <code>docs/CONFIGURACAO_FIREBASE.md</code>.</p></main>;
  if (state.loading) return <main className="setup" role="status"><Compass size={44}/><p>Verificando acesso…</p></main>;
  if (!state.user) return <Login/>;
  if (!state.authorized) return <main className="setup"><h1>Acesso administrativo necessário</h1><p role="alert">{state.error}</p><p>UID da sua conta: <code>{state.user.uid}</code></p>{logoutError&&<p role="alert">{logoutError}</p>}<button onClick={()=>{if(auth)void signOut(auth).catch(error=>setLogoutError(errorMessage(error)));}}>Sair e usar outra conta</button></main>;
  return <Dashboard email={state.user.email}/>;
}
