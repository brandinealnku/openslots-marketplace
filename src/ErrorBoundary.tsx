import { Component, type ErrorInfo, type ReactNode } from 'react';

type ErrorBoundaryProps = {
  children: ReactNode;
};

type ErrorBoundaryState = {
  hasError: boolean;
};

export default class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('OpenSlot failed to render.', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <main role="alert">
          <h1>OpenSlot could not load</h1>
          <p>Something went wrong while starting the application. Please refresh the page and try again.</p>
        </main>
      );
    }

    return this.props.children;
  }
}
