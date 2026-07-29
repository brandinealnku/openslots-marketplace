import {requireSupabase} from '../lib/supabase';
import {normalizeAuthError} from './authService';
export type UserRole='customer'|'provider'|'admin';
export interface Profile{id:string;role:UserRole;display_name:string|null;email:string|null;phone:string|null;account_status:string;role_selected_at:string|null}
export interface CustomerProfile{user_id:string;default_address_id:string|null;preferred_contact_method:'email'|'phone'|'text'|null}
export interface ProviderProfile{user_id:string;business_name:string;application_status:'draft'|'pending'|'approved'|'rejected'|'paused'|'suspended'|'more_information'}
async function currentId(){const {data,error}=await requireSupabase().auth.getUser();if(error||!data.user)throw normalizeAuthError(error||new Error('session expired'));return data.user.id}
export const profileService={
 async loadCurrentProfile(){const id=await currentId();const {data,error}=await requireSupabase().from('profiles').select('id,role,display_name,email,phone,account_status,role_selected_at').eq('id',id).maybeSingle();if(error)throw normalizeAuthError(error);return data as Profile|null},
 async updateProfile(input:{display_name?:string;phone?:string}){const id=await currentId();const {data,error}=await requireSupabase().from('profiles').update(input).eq('id',id).select('id,role,display_name,email,phone,account_status,role_selected_at').single();if(error)throw normalizeAuthError(error);return data as Profile},
 async selectInitialRole(role:'customer'|'provider'){const {data,error}=await requireSupabase().rpc('select_initial_role',{requested_role:role});if(error)throw normalizeAuthError(error);return data as UserRole},
 async loadCustomerProfile(){const id=await currentId();const {data,error}=await requireSupabase().from('customer_profiles').select('user_id,default_address_id,preferred_contact_method').eq('user_id',id).maybeSingle();if(error)throw normalizeAuthError(error);return data as CustomerProfile|null},
 async updateCustomerProfile(input:{preferred_contact_method:'email'|'phone'|'text'}){const id=await currentId();const {data,error}=await requireSupabase().from('customer_profiles').upsert({user_id:id,...input}).select().single();if(error)throw normalizeAuthError(error);return data as CustomerProfile},
 async loadProviderProfile(){const id=await currentId();const {data,error}=await requireSupabase().from('provider_profiles').select('user_id,business_name,application_status').eq('user_id',id).maybeSingle();if(error)throw normalizeAuthError(error);return data as ProviderProfile|null},
 isCustomerComplete(profile:Profile|null,customer:CustomerProfile|null){return Boolean(profile?.display_name&&profile.phone&&customer?.preferred_contact_method&&customer.default_address_id)},
};
