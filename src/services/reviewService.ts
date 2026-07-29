import {rest} from '../lib/supabase';
export const reviewService={create:(input:Record<string,unknown>,token:string)=>rest('reviews','',{method:'POST',headers:{Prefer:'return=representation'},body:JSON.stringify(input)},token)};
