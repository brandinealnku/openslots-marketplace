import type {AuthChangeEvent, Session} from '@supabase/supabase-js';
import {requireSupabase} from '../lib/supabase';

export type RegistrationRole='customer'|'provider';
export class AuthApplicationError extends Error { constructor(public code:string, message:string){super(message);this.name='AuthApplicationError'} }
export function normalizeAuthError(error:unknown):AuthApplicationError{
 const raw=error instanceof Error?error.message.toLowerCase():'';
 const status=typeof error==='object'&&error&&'status' in error?Number(error.status):0;
 if(raw.includes('invalid login'))return new AuthApplicationError('invalid_credentials','The email or password is incorrect.');
 if(raw.includes('already registered')||raw.includes('already been registered'))return new AuthApplicationError('already_registered','An account may already exist for this email. Try signing in or resetting your password.');
 if(raw.includes('email not confirmed'))return new AuthApplicationError('email_unconfirmed','Please verify your email before signing in.');
 if(raw.includes('weak')||raw.includes('password')&&raw.includes('least'))return new AuthApplicationError('weak_password','Use at least 8 characters, including a letter and a number.');
 if(raw.includes('expired')||raw.includes('otp'))return new AuthApplicationError('expired_link','This recovery or verification link is invalid or has expired.');
 if(status===429||raw.includes('rate limit'))return new AuthApplicationError('rate_limited','Too many attempts. Please wait a few minutes and try again.');
 if(raw.includes('fetch')||raw.includes('network')||!navigator.onLine)return new AuthApplicationError('network','OpenSlot cannot reach the network. Check your connection and try again.');
 if(raw.includes('session'))return new AuthApplicationError('session_expired','Your session expired. Please sign in again.');
 return new AuthApplicationError('unexpected','We could not complete that account request. Please try again.');
}
async function result<T>(work:Promise<{data:T;error:unknown}>):Promise<T>{const {data,error}=await work;if(error)throw normalizeAuthError(error);return data}
export const authService={
 signUp:(input:{email:string;password:string;fullName:string;role:RegistrationRole})=>result(requireSupabase().auth.signUp({email:input.email,password:input.password,options:{data:{full_name:input.fullName,requested_role:input.role},emailRedirectTo:`${location.origin}${location.pathname}#/verify-email`}})),
 signIn:(email:string,password:string)=>result(requireSupabase().auth.signInWithPassword({email,password})),
 signOut:()=>result(requireSupabase().auth.signOut()),
 getSession:()=>result(requireSupabase().auth.getSession()),
 getUser:()=>result(requireSupabase().auth.getUser()),
 requestPasswordReset:(email:string)=>result(requireSupabase().auth.resetPasswordForEmail(email,{redirectTo:`${location.origin}${location.pathname}#/reset-password`})),
 updatePassword:(password:string)=>result(requireSupabase().auth.updateUser({password})),
 resendVerification:(email:string)=>result(requireSupabase().auth.resend({type:'signup',email,options:{emailRedirectTo:`${location.origin}${location.pathname}#/verify-email`}})),
 subscribeToAuthChanges:(callback:(event:AuthChangeEvent,session:Session|null)=>void)=>requireSupabase().auth.onAuthStateChange(callback),
};
