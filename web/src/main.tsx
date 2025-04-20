import React from 'react';
import ReactDOM from 'react-dom/client';
import { VisibilityProvider } from './providers/VisibilityProvider';
import { MantineProvider } from '@mantine/core';
import App from './App';
import FreezeWarning from './components/FreezeWarning';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <MantineProvider>
    <React.StrictMode>
      <VisibilityProvider>
        <App />
        {/* <FreezeWarning /> */}
      </VisibilityProvider>
    </React.StrictMode>
  </MantineProvider>,
);
