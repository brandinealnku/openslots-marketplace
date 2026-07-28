export const STORAGE_KEY='openslot-demo-v1';
export function loadState<T>(fallback:T):T{try{const raw=localStorage.getItem(STORAGE_KEY);return raw?JSON.parse(raw) as T:fallback}catch{return fallback}}
export function saveState<T>(state:T){try{localStorage.setItem(STORAGE_KEY,JSON.stringify(state));return true}catch{return false}}
export function resetState(){try{localStorage.removeItem(STORAGE_KEY);return true}catch{return false}}
