import { MD3LightTheme as DefaultTheme } from 'react-native-paper';

export const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#4F46E5',    // Indigo 600 - More modern than standard purple
    onPrimary: '#FFFFFF',
    secondary: '#10B981',  // Emerald 500
    onSecondary: '#FFFFFF',
    tertiary: '#F59E0B',   // Amber 500
    error: '#EF4444',      // Red 500
    background: '#F9FAFB', // Cool Gray 50
    surface: '#FFFFFF',
    surfaceVariant: '#F3F4F6', // Cool Gray 100
    onSurface: '#111827',  // Cool Gray 900
    onSurfaceVariant: '#4B5563', // Cool Gray 600
    outline: '#E5E7EB',    // Cool Gray 200
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },
  roundness: 16, // Smoother corners for cards
};

// Layout constants
export const SPACING = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
};

export const ACTIVITY_TYPES = [
  'Running',
  'Cycling',
  'Swimming',
  'Strength Training',
  'Yoga',
  'Walking',
  'Hiking',
  'Other',
];

export const EXERCISE_CATEGORIES = [
  'Upper Body',
  'Lower Body',
  'Core',
  'Cardio',
  'Flexibility',
  'Full Body',
];
