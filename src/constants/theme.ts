import { MD3LightTheme as DefaultTheme } from 'react-native-paper';

export const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#6200ee',
    secondary: '#03dac6',
    error: '#b00020',
    background: '#f6f6f6',
    surface: '#ffffff',
    text: '#000000',
  },
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
