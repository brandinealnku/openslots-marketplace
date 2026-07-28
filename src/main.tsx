import React, { Component, type ErrorInfo, type ReactNode } from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { StoreProvider } from './store';
import { STORAGE_KEY } from './utils/storage';
import './styles.css';

type ErrorBoundaryState = { hasError: boolean };

class AppErrorBoundary extends Component<{ children: ReactNode }, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    // Keep diagnostic details in developer tools without exposing them in the UI.
    console.error('OpenSlot failed during rendering.', error, info);
  }

  private clearAndRestart = () => {
    localStorage.removeItem(STORAGE_KEY);
    window.location.reload();
  };

  render() {
    if (this.state.hasError) {
      return (
        <main className="startup-error" role="alert">
          <div className="panel">
            <h1>We hit a problem</h1>
            <p>OpenSlot could not start. Try resetting the demo data or refreshing the page.</p>
            <div className="hero-actions">
              <button className="button" onClick={() => window.location.reload()}>Refresh the page</button>
              <button className="button secondary" onClick={this.clearAndRestart}>Clear OpenSlot LocalStorage and restart</button>
            </div>
          </div>
        </main>
      );
    }

    return this.props.children;
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AppErrorBoundary>
      <StoreProvider><App /></StoreProvider>
    </AppErrorBoundary>
  </React.StrictMode>,
);
