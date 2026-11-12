import { useEffect, useState } from 'react';
import { onAuthStateChanged, type User } from 'firebase/auth';
import { doc, onSnapshot } from 'firebase/firestore';
import { auth, db } from '../firebase/client';
import { errorMessage } from '../services/errors';
export type AdminState = { loading: boolean; user: User | null; authorized: boolean; error: string };
export function useAdmin(): AdminState {
  const [state, setState] = useState<AdminState>({loading:true,user:null,authorized:false,error:''});
  useEffect(() => {
    if (!auth || !db) { setState({loading:false,user:null,authorized:false,error:''}); return; }
    const firestore = db;
    let stopRole: (()=>void) | undefined;
    const stopAuth = onAuthStateChanged(auth, user => {
      stopRole?.();
      setState({loading:!!user,user,authorized:false,error:''});
      if (!user) return;
      stopRole = onSnapshot(doc(firestore,'admins',user.uid), snapshot => {
        setState({loading:false,user,authorized:snapshot.exists(),error:snapshot.exists()?'':'Sua conta não tem autorização administrativa. Cadastre admins/UID pelo console Firebase.'});
      }, error => setState({loading:false,user,authorized:false,error:errorMessage(error)}));
    }, error => setState({loading:false,user:null,authorized:false,error:errorMessage(error)}));
    return () => { stopAuth(); stopRole?.(); };
  }, []);
  return state;
}
