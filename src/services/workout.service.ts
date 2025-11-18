import { supabase } from './supabase';
import { WorkoutLog } from '../types/workout.types';

export const workoutService = {
  // Get all workouts
  async getAllWorkouts(): Promise<WorkoutLog[]> {
    const { data, error } = await supabase
      .from('workout_logs')
      .select('*')
      .order('date', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  // Get workouts for a specific date
  async getWorkoutsByDate(date: string): Promise<WorkoutLog[]> {
    const { data, error } = await supabase
      .from('workout_logs')
      .select('*')
      .eq('date', date);

    if (error) throw error;
    return data || [];
  },

  // Get workouts for a date range
  async getWorkoutsByDateRange(startDate: string, endDate: string): Promise<WorkoutLog[]> {
    const { data, error } = await supabase
      .from('workout_logs')
      .select('*')
      .gte('date', startDate)
      .lte('date', endDate)
      .order('date', { ascending: true });

    if (error) throw error;
    return data || [];
  },

  // Create a new workout
  async createWorkout(workout: Omit<WorkoutLog, 'id' | 'created_at' | 'updated_at'>): Promise<WorkoutLog> {
    const { data, error } = await supabase
      .from('workout_logs')
      .insert([workout])
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Update a workout
  async updateWorkout(id: string, workout: Partial<WorkoutLog>): Promise<WorkoutLog> {
    const { data, error } = await supabase
      .from('workout_logs')
      .update(workout)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Delete a workout
  async deleteWorkout(id: string): Promise<void> {
    const { error } = await supabase
      .from('workout_logs')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },

  // Upload watch screenshot
  async uploadWatchScreenshot(uri: string, workoutId: string): Promise<string> {
    const response = await fetch(uri);
    const blob = await response.blob();
    const arrayBuffer = await new Response(blob).arrayBuffer();
    const fileName = `${workoutId}-${Date.now()}.jpg`;

    const { data, error } = await supabase.storage
      .from('workout-screenshots')
      .upload(fileName, arrayBuffer, {
        contentType: 'image/jpeg',
      });

    if (error) throw error;

    const { data: urlData } = supabase.storage
      .from('workout-screenshots')
      .getPublicUrl(fileName);

    return urlData.publicUrl;
  },
};
