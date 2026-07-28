import {createContext,useContext,useEffect,useState,type ReactNode} from 'react';
import {applications,initialBookings,openings as seedOpenings} from './data/mockData'; import {loadState,resetState,saveState} from './utils/storage'; import type {Application,Booking,Opening,Role} from './types';
interface State{role:Role;openings:Opening[];bookings:Booking[];saved:string[];applications:Application[]}
const initial:State={role:'customer',openings:seedOpenings,bookings:initialBookings,saved:[],applications};
interface Store extends State{setRole:(r:Role)=>void;post:(o:Opening)=>void;book:(b:Booking)=>void;toggleSaved:(id:string)=>void;approve:(id:string,status:'Approved'|'Rejected')=>void;reset:()=>void}
const C=createContext<Store|null>(null);
export function StoreProvider({children}:{children:ReactNode}){const [s,setS]=useState(()=>loadState(initial));useEffect(()=>{saveState(s)},[s]);const value:Store={...s,setRole:role=>setS({...s,role}),post:o=>setS({...s,openings:[o,...s.openings]}),book:b=>setS({...s,bookings:[b,...s.bookings],openings:s.openings.map(o=>o.id===b.openingId?{...o,status:'booked'}:o)}),toggleSaved:id=>setS({...s,saved:s.saved.includes(id)?s.saved.filter(x=>x!==id):[...s.saved,id]}),approve:(id,status)=>setS({...s,applications:s.applications.map(a=>a.id===id?{...a,status}:a)}),reset:()=>{if(confirm('Reset all OpenSlot demo changes?')){resetState();setS(initial)}}};return <C.Provider value={value}>{children}</C.Provider>}
export const useStore=()=>{const x=useContext(C);if(!x)throw new Error('Store missing');return x};
