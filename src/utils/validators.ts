import { WorkoutFormData } from '../types/workout.types';

export const validateWorkoutForm = (formData: WorkoutFormData): string[] => {
  const errors: string[] = [];

  if (!formData.date) {
    errors.push('Date is required');
  }

  if (!formData.activity_type) {
    errors.push('Activity type is required');
  }

  if (!formData.calories || parseInt(formData.calories) <= 0) {
    errors.push('Calories must be a positive number');
  }

  if (!formData.duration || parseInt(formData.duration) <= 0) {
    errors.push('Duration must be a positive number');
  }

  if (formData.distance && parseFloat(formData.distance) < 0) {
    errors.push('Distance must be a positive number');
  }

  if (formData.heart_rate && parseInt(formData.heart_rate) <= 0) {
    errors.push('Heart rate must be a positive number');
  }

  return errors;
};
