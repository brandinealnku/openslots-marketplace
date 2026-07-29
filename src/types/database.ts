export type Json=string|number|boolean|null|{[key:string]:Json|undefined}|Json[];
export interface Database {
 public:{Tables:{
  bookings:{Row:{id:string;confirmation_code:string;opening_id:string;customer_id:string;provider_id:string;service_address_id:string;status:string;service_subtotal:number;addon_total:number;booking_fee:number;estimated_tax:number;total:number;provider_payout_estimate:number;provider_response_due_at:string|null;created_at:string}};
  profiles:{Row:{id:string;role:'customer'|'provider'|'admin';display_name:string|null;phone:string|null;account_status:string}};
  appointment_openings:{Row:{id:string;provider_id:string;provider_service_id:string;start_at:string;end_at:string;status:string;booking_method:string;fixed_price:number;expiration_at:string}};
 }};
}
