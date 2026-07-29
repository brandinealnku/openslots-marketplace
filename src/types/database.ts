export type Json=string|number|boolean|null|{[key:string]:Json|undefined}|Json[];
type Table<Row extends Record<string,unknown>>={Row:Row;Insert:Partial<Row>;Update:Partial<Row>;Relationships:[]};
export interface Database {public:{Tables:{
 bookings:Table<{id:string;confirmation_code:string;opening_id:string;customer_id:string;provider_id:string;service_address_id:string;status:string;service_subtotal:number;addon_total:number;booking_fee:number;estimated_tax:number;total:number;provider_payout_estimate:number;provider_response_due_at:string|null;created_at:string}>;
 profiles:Table<{id:string;role:'customer'|'provider'|'admin';display_name:string|null;email:string|null;phone:string|null;avatar_path:string|null;account_status:string;role_selected_at:string|null;created_at:string;updated_at:string}>;
 customer_profiles:Table<{user_id:string;default_address_id:string|null;preferred_contact_method:'email'|'phone'|'text'|null;created_at:string;updated_at:string}>;
 provider_profiles:Table<{user_id:string;business_name:string;application_status:'draft'|'pending'|'approved'|'rejected'|'paused'|'suspended'|'more_information';created_at:string;updated_at:string}>;
 addresses:Table<{id:string;user_id:string;label:string;address_line_1:string;address_line_2:string|null;city:string;state:string;postal_code:string;is_default:boolean;created_at:string;updated_at:string}>;
};Views:Record<string,never>;Functions:{select_initial_role:{Args:{requested_role:'customer'|'provider'};Returns:'customer'|'provider'}};Enums:{user_role:'customer'|'provider'|'admin';application_status:'draft'|'pending'|'approved'|'rejected'|'paused'|'suspended'|'more_information'};CompositeTypes:Record<string,never>}}
