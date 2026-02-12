import { createTheme } from '@mui/material/styles';

// Design tokens extracted from Figma
export const theme = createTheme({
  palette: {
    primary: {
      main: '#1976D2',
    },
    secondary: {
      main: '#FF9800',
    },
    error: {
      main: '#D32F2F',
    },
    success: {
      main: '#388E3C',
    },
  },
  typography: {
    fontFamily: 'Roboto, sans-serif',
  },
  spacing: 8, // 8px grid system
});
