import { format, parseISO } from 'date-fns';

export const formatDate = (date: string | Date): string => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date;
  return format(dateObj, 'MMM dd, yyyy');
};

export const formatTime = (minutes: number): string => {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;

  if (hours > 0) {
    return `${hours}h ${mins}m`;
  }
  return `${mins}m`;
};

export const formatDistance = (distance: number | undefined): string => {
  if (!distance) return 'N/A';
  return `${distance.toFixed(2)} km`;
};

export const formatCalories = (calories: number): string => {
  return `${calories} cal`;
};

export const formatHeartRate = (heartRate: number | undefined): string => {
  if (!heartRate) return 'N/A';
  return `${heartRate} bpm`;
};
