export type AppMode = 'development' | 'production' | 'demo';
export type ProviderBillingMode = 'disabled' | 'test' | 'live';

export interface AppEnvironment { mode: AppMode; billingMode: ProviderBillingMode; stripePublishableKey?: string; supabaseUrl?: string; supabaseAnonKey?: string; connected: boolean }

export function validateEnvironment(values: Record<string, string | undefined>): AppEnvironment {
  const mode = (values.VITE_APP_MODE || 'development') as AppMode;
  const billingMode = (values.VITE_PROVIDER_BILLING_MODE || 'disabled') as ProviderBillingMode;
  if (!['development', 'production', 'demo'].includes(mode)) throw new Error('VITE_APP_MODE must be development, production, or demo.');
  if (!['disabled', 'test', 'live'].includes(billingMode)) throw new Error('VITE_PROVIDER_BILLING_MODE must be disabled, test, or live.');
  const supabaseUrl = values.VITE_SUPABASE_URL?.trim();
  const supabaseAnonKey = values.VITE_SUPABASE_ANON_KEY?.trim();
  if (mode !== 'demo' && (!supabaseUrl || !supabaseAnonKey)) throw new Error('OpenSlot needs VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY. Use VITE_APP_MODE=demo only for local mock data.');
  if (supabaseUrl && !/^https:\/\/.+/.test(supabaseUrl)) throw new Error('VITE_SUPABASE_URL must be an HTTPS URL.');
  if (/service.role|service_role/i.test(supabaseAnonKey || '')) throw new Error('Never place a Supabase service-role key in browser environment variables.');
  const stripePublishableKey=values.VITE_STRIPE_PUBLISHABLE_KEY?.trim();
  if (stripePublishableKey && !stripePublishableKey.startsWith('pk_')) throw new Error('VITE_STRIPE_PUBLISHABLE_KEY must be a Stripe publishable key.');
  if (mode==='demo' && billingMode!=='disabled') throw new Error('Demo mode requires provider billing to be disabled.');
  return {mode, billingMode, stripePublishableKey, supabaseUrl, supabaseAnonKey, connected: Boolean(supabaseUrl && supabaseAnonKey)};
}

export const env = import.meta.env.MODE === 'test'
  ? validateEnvironment({VITE_APP_MODE:'demo'})
  : validateEnvironment(import.meta.env as Record<string, string | undefined>);
