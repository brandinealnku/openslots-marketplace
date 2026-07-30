import type {Role} from './types';
export type MobileNavItem={to:string;label:string;emphasis?:boolean};
export function mobileNavigation(role:Role|null,authenticated:boolean):MobileNavItem[]{
  if(!authenticated)return [{to:'/',label:'Home'},{to:'/search',label:'Search'},{to:'/how-it-works',label:'How it works'},{to:'/login',label:'Log in'}];
  if(role==='provider')return [{to:'/provider',label:'Dashboard'},{to:'/provider/schedule',label:'Schedule'},{to:'/provider/openings/new',label:'Post',emphasis:true},{to:'/provider/earnings',label:'Earnings'},{to:'/provider/application-status',label:'Account'}];
  if(role==='admin')return [{to:'/admin',label:'Admin'},{to:'/admin',label:'Providers'},{to:'/search',label:'Listings'},{to:'/admin',label:'Support'},{to:'/account-status',label:'Account'}];
  return [{to:'/',label:'Home'},{to:'/search',label:'Search'},{to:'/customer/bookings',label:'Bookings'},{to:'/customer/saved',label:'Saved'},{to:'/customer/profile',label:'Account'}];
}
