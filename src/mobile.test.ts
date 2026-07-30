import {describe,expect,it} from 'vitest';
import {mobileNavigation} from './mobile';
describe('role-aware mobile navigation',()=>{
  it('keeps protected routes out when signed out',()=>expect(mobileNavigation(null,false).map(x=>x.label)).toEqual(['Home','Search','How it works','Log in']));
  it('provides customer destinations',()=>expect(mobileNavigation('customer',true).map(x=>x.label)).toEqual(['Home','Search','Bookings','Saved','Account']));
  it('emphasizes provider posting',()=>expect(mobileNavigation('provider',true).find(x=>x.emphasis)?.to).toBe('/provider/openings/new'));
  it('provides compact admin operations',()=>expect(mobileNavigation('admin',true)).toHaveLength(5));
});
