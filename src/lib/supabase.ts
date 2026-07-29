import {env} from './env';

// A small, dependency-free Supabase HTTP adapter. It uses only the public anon key;
// authorization remains enforced by PostgreSQL RLS. It can be replaced with
// @supabase/supabase-js without changing the service interfaces.
export async function supabaseRequest<T>(path:string, init:RequestInit={}, accessToken?:string):Promise<T>{
  if(!env.connected) throw new Error('Supabase is unavailable in demo mode.');
  const response=await fetch(`${env.supabaseUrl}/${path}`,{...init,headers:{apikey:env.supabaseAnonKey!,Authorization:`Bearer ${accessToken||env.supabaseAnonKey}`,'Content-Type':'application/json',...init.headers}});
  const body=await response.json().catch(()=>null);
  if(!response.ok) throw Object.assign(new Error('The marketplace request could not be completed.'),{status:response.status,technical:body});
  return body as T;
}

export const rest=<T>(table:string,query='',init:RequestInit={},token?:string)=>supabaseRequest<T>(`rest/v1/${table}${query}`,init,token);
