import {createClient} from '@supabase/supabase-js';
import {env} from './env';
import type {Database} from '../types/database';

/** The sole browser Supabase client. Demo mode never imports/uses this client through AuthProvider. */
export const supabase = env.connected
  ? createClient<Database>(env.supabaseUrl!, env.supabaseAnonKey!, {
      auth: {persistSession: true, autoRefreshToken: true, detectSessionInUrl: true},
    })
  : null;

export function requireSupabase() {
  if (!supabase) throw new Error('configuration');
  return supabase;
}

// Compatibility adapter for existing marketplace services; authentication uses the SDK above.
export async function supabaseRequest<T>(path:string,init:RequestInit={},accessToken?:string):Promise<T>{
 if(!env.connected)throw new Error('Supabase is unavailable in demo mode.');
 const response=await fetch(`${env.supabaseUrl}/${path}`,{...init,headers:{apikey:env.supabaseAnonKey!,Authorization:`Bearer ${accessToken||env.supabaseAnonKey}`,'Content-Type':'application/json',...init.headers}});
 const body=await response.json().catch(()=>null);if(!response.ok)throw Object.assign(new Error('The marketplace request could not be completed.'),{status:response.status,technical:body});return body as T;
}
export const rest=<T>(table:string,query='',init:RequestInit={},token?:string)=>supabaseRequest<T>(`rest/v1/${table}${query}`,init,token);
