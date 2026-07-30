import {describe,expect,it} from 'vitest';
import {demoProviderAccess} from '../services/billingService';
import {hasMarketplaceAccess,statusMessage} from './status';
describe('provider subscription access',()=>{it.each([['none',false],['trialing',true],['active',true],['past_due',false]] as const)('%s access',(status,expected)=>{const value=demoProviderAccess(status);expect(hasMarketplaceAccess(value)).toBe(expected);expect(value.billing_required).toBe(!expected)});it('explains past due status',()=>expect(statusMessage('past_due')).toMatch(/Payment failed/));});
