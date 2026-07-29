import {supabaseRequest} from '../lib/supabase';
export interface AuthSession{access_token:string;refresh_token:string;expires_in:number;user:{id:string;email?:string;email_confirmed_at?:string}}
export const authService={
 signIn:(email:string,password:string)=>supabaseRequest<AuthSession>('auth/v1/token?grant_type=password',{method:'POST',body:JSON.stringify({email,password})}),
 register:(email:string,password:string,role:'customer'|'provider')=>supabaseRequest<{user:AuthSession['user']}>('auth/v1/signup',{method:'POST',body:JSON.stringify({email,password,data:{requested_role:role}})}),
 resetPassword:(email:string,redirectTo:string)=>supabaseRequest('auth/v1/recover',{method:'POST',body:JSON.stringify({email,redirect_to:redirectTo})}),
 refresh:(refresh_token:string)=>supabaseRequest<AuthSession>('auth/v1/token?grant_type=refresh_token',{method:'POST',body:JSON.stringify({refresh_token})}),
 signOut:(token:string)=>supabaseRequest('auth/v1/logout',{method:'POST'},token),
};
