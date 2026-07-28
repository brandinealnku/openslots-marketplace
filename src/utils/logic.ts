import {FEES} from '../config'; import type {Booking,Opening} from '../types';
export const calculatePrice=(base:number,addons:number[])=>{const addonTotal=addons.reduce((a,b)=>a+b,0),tax=+(base+addonTotal).toFixed(2)*FEES.taxRate;return {base,addonTotal,bookingFee:FEES.bookingFee,tax:+tax.toFixed(2),total:+(base+addonTotal+FEES.bookingFee+tax).toFixed(2),platformFee:+((base+addonTotal)*FEES.platformRate).toFixed(2)}};
export const isExpired=(opening:Opening,now=new Date())=>new Date(opening.expiresAt)<=now;
export const filterOpenings=(items:Opening[],q:{service?:string;maxPrice?:number;rating?:number},ratings:Record<string,number>={})=>items.filter(x=>x.status==='active'&&(!q.service||x.service===q.service)&&(!q.maxPrice||x.price<=q.maxPrice)&&(!q.rating||(ratings[x.providerId]||0)>=q.rating));
export const sortOpenings=(items:Opening[],sort:string)=>[...items].sort((a,b)=>sort==='price'?a.price-b.price:sort==='distance'?a.distance-b.distance:sort==='rating'?0:new Date(`${a.date} ${a.time}`).getTime()-new Date(`${b.date} ${b.time}`).getTime());
export const updateBookingStatus=(booking:Booking,status:Booking['status'])=>({...booking,status});
