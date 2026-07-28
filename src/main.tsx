import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import ErrorBoundary from './ErrorBoundary';
import { StoreProvider } from './store';
https://github.com/brandinealnku/openslots-marketplace/pull/3/conflict?name=src%252Fmain.tsx&ancestor_oid=e53615d73bd7adeab3b78b1fefe524fd8d9aeb2b&base_oid=6e0d05ffb21c345b835dfbcd3dcd5e56c4f814fe&head_oid=9c33d118d32a4c52f75af68d38c1c8431bbfac79import './styles.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ErrorBoundary>
      <StoreProvider>
        <App />
      </StoreProvider>
    </ErrorBoundary>
  </React.StrictMode>,
);
