import { create } from 'zustand';
import { WorkoutLog } from '../types/workout.types';
import { workoutService } from '../services/workout.service';

interface WorkoutStore {
  workouts: WorkoutLog[];
  loading: boolean;
  error: string | null;
  fetchWorkouts: () => Promise<void>;
  addWorkout: (workout: Omit<WorkoutLog, 'id' | 'created_at' | 'updated_at'>) => Promise<void>;
  deleteWorkout: (id: string) => Promise<void>;
  getWorkoutsByDate: (date: string) => WorkoutLog[];
}

export const useWorkoutStore = create<WorkoutStore>((set, get) => ({
  workouts: [],
  loading: false,
  error: null,

  fetchWorkouts: async () => {
    set({ loading: true, error: null });
    try {
      const workouts = await workoutService.getAllWorkouts();
      set({ workouts, loading: false });
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
    }
  },

  addWorkout: async (workout) => {
    set({ loading: true, error: null });
    try {
      const newWorkout = await workoutService.createWorkout(workout);
      set((state) => ({
        workouts: [newWorkout, ...state.workouts],
        loading: false,
      }));
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
      throw error;
    }
  },

  deleteWorkout: async (id) => {
    set({ loading: true, error: null });
    try {
      await workoutService.deleteWorkout(id);
      set((state) => ({
        workouts: state.workouts.filter((w) => w.id !== id),
        loading: false,
      }));
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
      throw error;
    }
  },

  getWorkoutsByDate: (date: string) => {
    const workouts = get().workouts;
    return workouts.filter((w) => w.date.startsWith(date));
  },
}));
