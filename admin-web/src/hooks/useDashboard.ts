import { useEffect, useState } from 'react';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '../firebase/client';
import type { Checkin, Estande } from '../types';
import { errorMessage } from '../services/errors';
export function useDashboard() {
  const [stands,setStands] = useState<Estande[]>([]);
  const [checkins,setCheckins] = useState<Checkin[]>([]);
  const [ready,setReady] = useState({stands:false,checkins:false});
  const [errors,setErrors] = useState({stands:'',checkins:''});
  useEffect(() => {
    if (!db) return;
    const stopStands = onSnapshot(collection(db,'estandes'), snapshot => {
      setStands(snapshot.docs.map(doc => ({...doc.data(),id:doc.id} as Estande)).sort((a,b)=>a.nome.localeCompare(b.nome,'pt-BR')));
      setReady(r=>({...r,stands:true})); setErrors(e=>({...e,stands:''}));
    }, error=> {setErrors(e=>({...e,stands:errorMessage(error)}));setReady(r=>({...r,stands:true}));});
    const stopCheckins = onSnapshot(collection(db,'checkins'), snapshot => {
      setCheckins(snapshot.docs.map(doc=>({...doc.data(),id:doc.id} as Checkin)));
      setReady(r=>({...r,checkins:true}));setErrors(e=>({...e,checkins:''}));
    }, error=> {setErrors(e=>({...e,checkins:errorMessage(error)}));setReady(r=>({...r,checkins:true}));});
    return ()=> {stopStands();stopCheckins();};
  },[]);
  return {stands,checkins,loading:!ready.stands || !ready.checkins,error:errors.stands || errors.checkins};
}
