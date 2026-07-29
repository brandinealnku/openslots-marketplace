import {rest} from '../lib/supabase';
export const adminService={applications:(token:string)=>rest('provider_profiles','?select=*&order=created_at.desc',{},token),updateApplication:(providerId:string,status:string,token:string)=>rest('provider_profiles',`?user_id=eq.${providerId}`,{method:'PATCH',body:JSON.stringify({application_status:status})},token)};
