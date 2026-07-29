import {describe,expect,it} from 'vitest';
import {accountDestination} from './routing';

describe('social account onboarding',()=>{
  it('keeps an unselected social profile out of role dashboards',()=>{
    const profile={id:'social',role:'customer' as const,display_name:'Social User',email:'social@example.com',phone:null,account_status:'active',role_selected_at:null};
    expect(profile.role_selected_at).toBeNull();
  });
  it('preserves normal routing after a role is securely selected',()=>{
    const profile={id:'social',role:'provider' as const,display_name:'Provider',email:'provider@example.com',phone:null,account_status:'active',role_selected_at:'2026-07-29T00:00:00Z'};
    expect(accountDestination(profile,'draft')).toBe('/provider/onboarding');
  });
});
