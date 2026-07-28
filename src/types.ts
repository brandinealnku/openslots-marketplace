export type Role='customer'|'provider'|'admin';
export type BookingStatus='Requested'|'Confirmed'|'Provider en route'|'In progress'|'Completed'|'Cancelled';
export interface Provider {id:string; business:string; name:string; initials:string; rating:number; reviews:number; jobs:number; years:number; area:string; bio:string; insured:boolean}
export interface Addon {name:string;price:number}
export interface Opening {id:string;providerId:string;service:string;date:string;time:string;duration:number;price:number;distance:number;instant:boolean;description:string;included:string[];addons:Addon[];expiresAt:string;size:string;status:'active'|'booked'|'paused'|'expired'}
export interface Booking {id:string;openingId:string;providerId:string;service:string;date:string;time:string;address:string;total:number;status:BookingStatus}
export interface Application {id:string;business:string;owner:string;submitted:string;status:'Pending'|'Approved'|'Rejected'}
