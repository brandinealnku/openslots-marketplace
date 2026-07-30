import {env} from '../lib/env';
import {requireSupabase} from '../lib/supabase';
import {normalizeError} from './errors';
export type SubscriptionStatus='none'|'trialing'|'active'|'past_due'|'unpaid'|'canceled'|'incomplete'|'incomplete_expired'|'paused';
export interface ProviderAccess {provider_approval_status:string;account_status:string;subscription_status:SubscriptionStatus;current_plan:string|null;trial_end:string|null;current_period_end:string|null;cancel_at_period_end:boolean;can_publish:boolean;billing_required:boolean;required_next_action:string}
export interface Plan {code:string;display_name:string;description:string;billing_interval:'trial'|'month'|'year';trial_days:number;active_opening_limit:number;monthly_publishing_limit:number|null;sort_order:number}
function ensureCallable(){if(env.mode==='demo')throw new Error('Billing actions are unavailable in the isolated demo.');if(env.billingMode==='disabled')throw new Error('Provider billing is disabled.');}
async function invoke(name:string,body?:Record<string,unknown>){ensureCallable();const {data,error}=await requireSupabase().functions.invoke(name,{body:body??{}});if(error)throw normalizeError(error);if(!data?.url||!/^https:\/\/checkout\.stripe\.com\//.test(data.url)&&!/^https:\/\/billing\.stripe\.com\//.test(data.url))throw new Error('Billing service returned an invalid URL.');return data.url as string}
export const billingService={
 async access():Promise<ProviderAccess>{if(env.mode==='demo')return demoProviderAccess('trialing');const {data,error}=await requireSupabase().rpc('get_provider_marketplace_access' as never);if(error)throw normalizeError(error);return (data as unknown as ProviderAccess[])[0]},
 async plans():Promise<Plan[]>{if(env.mode==='demo')return [];const {data,error}=await requireSupabase().rpc('list_provider_subscription_plans' as never);if(error)throw normalizeError(error);return data as unknown as Plan[]},
 checkout(planCode:string){return invoke('create-provider-subscription-checkout',{planCode})},portal(){return invoke('create-provider-billing-portal')}
};
export function demoProviderAccess(status:SubscriptionStatus):ProviderAccess{return{provider_approval_status:'approved (simulated)',account_status:'active (simulated)',subscription_status:status,current_plan:'trial (simulated)',trial_end:null,current_period_end:null,cancel_at_period_end:false,can_publish:status==='trialing'||status==='active',billing_required:!['trialing','active'].includes(status),required_next_action:['trialing','active'].includes(status)?'none':'choose_plan'}}
