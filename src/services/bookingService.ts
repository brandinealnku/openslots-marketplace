import {supabaseRequest} from '../lib/supabase';
import type {Database} from '../types/database';
type Booking=Database['public']['Tables']['bookings']['Row'];
export interface CreateBookingInput{openingId:string;serviceAddressId:string;propertySize?:string;grassHeight?:string;gateAccess?:string;petsPresent:boolean;specialInstructions?:string;preferredContactMethod:'email'|'phone'|'text';addonIds:string[]}
export const bookingService={
 createAtomic:(input:CreateBookingInput,token:string)=>supabaseRequest<Booking[]>('rest/v1/rpc/create_booking',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify({p_opening_id:input.openingId,p_service_address_id:input.serviceAddressId,p_property_size:input.propertySize,p_grass_height:input.grassHeight,p_gate_access:input.gateAccess,p_pets_present:input.petsPresent,p_special_instructions:input.specialInstructions,p_preferred_contact_method:input.preferredContactMethod,p_addon_ids:input.addonIds})},token),
 mine:(token:string)=>supabaseRequest<Booking[]>('rest/v1/bookings?select=*&order=start_at.desc',{},token),
 transition:(bookingId:string,status:string,reason:string|undefined,token:string)=>supabaseRequest('rest/v1/rpc/transition_booking',{method:'POST',body:JSON.stringify({p_booking_id:bookingId,p_new_status:status,p_reason:reason})},token),
};
