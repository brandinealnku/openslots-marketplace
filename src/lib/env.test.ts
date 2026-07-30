import {describe,expect,it} from 'vitest';import {validateEnvironment} from './env';
describe('environment validation',()=>{it('permits explicit demo mode',()=>expect(validateEnvironment({VITE_APP_MODE:'demo'}).connected).toBe(false));it('requires connected credentials',()=>expect(()=>validateEnvironment({VITE_APP_MODE:'production'})).toThrow(/VITE_SUPABASE/));it('rejects service role material',()=>expect(()=>validateEnvironment({VITE_APP_MODE:'production',VITE_SUPABASE_URL:'https://x.supabase.co',VITE_SUPABASE_ANON_KEY:'service_role'})).toThrow(/service-role/))});

describe('provider billing environment',()=>{
  it('keeps billing disabled unless explicitly selected',()=>expect(validateEnvironment({VITE_APP_MODE:'demo'}).billingMode).toBe('disabled'));
  it('accepts explicit Stripe test mode without inferring from a key',()=>expect(validateEnvironment({VITE_APP_MODE:'development',VITE_SUPABASE_URL:'https://test.supabase.co',VITE_SUPABASE_ANON_KEY:'anon',VITE_PROVIDER_BILLING_MODE:'test',VITE_STRIPE_PUBLISHABLE_KEY:'pk_test_example'}).billingMode).toBe('test'));
  it('prevents demo Stripe calls through configuration',()=>expect(()=>validateEnvironment({VITE_APP_MODE:'demo',VITE_PROVIDER_BILLING_MODE:'test'})).toThrow(/Demo mode/));
});
