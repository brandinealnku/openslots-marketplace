import type {ReactNode} from 'react';import {Navigate,useLocation} from 'react-router-dom';import {useAuth} from './AuthProvider';
const blocked=(s:string|null)=>s==='suspended'||s==='closed'||s==='paused';
function Guard({children,roles,approved=false}:{children:ReactNode;roles?:string[];approved?:boolean}){const a=useAuth(),location=useLocation();if(a.isLoading||a.profileLoading)return <div className="page narrow auth-state" role="status">Loading your OpenSlot account…</div>;if(!a.isAuthenticated)return <Navigate to="/login" replace state={{from:location.pathname}}/>;if(blocked(a.accountStatus))return <Navigate to="/account-status" replace/>;if(!a.profile)return <Navigate to="/account-status" replace/>;if(roles&&!roles.includes(a.role!))return <div className="page narrow auth-state" role="alert"><h1>That page isn’t available to this account</h1><p>Use your account dashboard to continue.</p></div>;if(approved&&a.providerApplicationStatus!=='approved')return <Navigate to="/provider/application-status" replace/>;return children}
export const RequireAuth=({children}:{children:ReactNode})=><Guard>{children}</Guard>;
export const RequireCustomer=({children}:{children:ReactNode})=><Guard roles={['customer']}>{children}</Guard>;
export const RequireProvider=({children}:{children:ReactNode})=><Guard roles={['provider']}>{children}</Guard>;
export const RequireApprovedProvider=({children}:{children:ReactNode})=><Guard roles={['provider']} approved>{children}</Guard>;
export const RequireAdmin=({children}:{children:ReactNode})=><Guard roles={['admin']}>{children}</Guard>;
